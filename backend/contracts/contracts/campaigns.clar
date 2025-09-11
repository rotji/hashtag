;; comprehensive-campaign-contract.clar
;;
;; This contract manages brand campaigns and rewards users with a fungible token
;; for social media mentions, designed to be updated by a trusted off-chain oracle.
;;
;; Features:
;; - Fungible Token for reward points ("reward-points").
;; - Brands can create campaigns and fund them with these tokens.
;; - A trusted Oracle can award points to users for verified off-chain actions.
;; - Users can claim their earned points.
;; - Brands can manage their campaign budget and status.

;; ---
;; Constants & Errors
;; ---
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ORACLE_PRINCIPAL tx-sender) ;; Initially the deployer, can be changed.

;; Error Codes
(define-constant ERR_UNAUTHORIZED (err u101))
(define-constant ERR_CAMPAIGN_NOT_FOUND (err u102))
(define-constant ERR_CAMPAIGN_INACTIVE (err u103))
(define-constant ERR_INSUFFICIENT_BUDGET (err u104))
(define-constant ERR_NO_REWARDS_TO_CLAIM (err u105))
(define-constant ERR_CAMPAIGN_ALREADY_EXISTS (err u106))


;; ---
;; Fungible Token for Rewards
;; ---
(define-fungible-token reward-points)


;; ---
;; Data Storage
;; ---

;; A counter for unique campaign IDs
(define-data-var campaign-id-counter uint u0)

;; A map to store campaign details
;; Key: uint (campaign-id)
;; Value: A tuple with campaign properties
(define-map campaigns uint {
  brand-owner: principal,
  name: (string-ascii 64),
  total-budget: uint,
  reward-per-mention: uint,
  is-active: bool
})

;; A map to store rewards earned by a user for a campaign before they are claimed.
;; This acts as a pending balance.
;; Key: A tuple of (uint, principal) -> (campaign-id, user-principal)
;; Value: uint (amount of pending rewards)
(define-map user-pending-rewards { campaign-id: uint, user: principal } uint)


;; ---
;; Administrative & Oracle Functions
;; ---

;; @desc Awards points to a user for a verified mention.
;; @desc ONLY callable by the designated Oracle.
;; @param campaign-id: The campaign to award for.
;; @param user: The user who earned the reward.
;; @returns (ok bool) or an error.
(define-public (award-mention (campaign-id uint) (user principal))
  (begin
    (asserts! (is-eq tx-sender ORACLE_PRINCIPAL) ERR_UNAUTHORIZED)

    (let
      ((campaign (unwrap! (map-get? campaigns campaign-id) ERR_CAMPAIGN_NOT_FOUND))
       (reward-amount (get reward-per-mention campaign))
       (current-pending-rewards (get-user-rewards-for-campaign campaign-id user)))

      (asserts! (get is-active campaign) ERR_CAMPAIGN_INACTIVE)
      (asserts! (>= (get total-budget campaign) reward-amount) ERR_INSUFFICIENT_BUDGET)

      ;; Update the campaign's budget
      (map-set campaigns campaign-id
        (merge campaign { total-budget: (- (get total-budget campaign) reward-amount) }))

      ;; Update the user's pending rewards
      (map-set user-pending-rewards { campaign-id: campaign-id, user: user }
        (+ current-pending-rewards reward-amount))

      (ok true)
    )
  )
)


;; ---
;; Brand (Campaign Owner) Functions
;; ---

;; @desc Creates a new campaign.
;; @param name: The name of the campaign.
;; @param initial-budget: The total amount of reward-points to fund the campaign with.
;; @param reward-per-mention: How many points to award for each mention.
;; @returns (ok uint) with the new campaign ID, or an error.
(define-public (create-campaign (name (string-ascii 64)) (initial-budget uint) (reward-per-mention uint))
  (let ((new-id (+ (var-get campaign-id-counter) u1)))
    ;; The brand must have enough reward-points to fund the campaign
    (try! (ft-transfer? reward-points initial-budget tx-sender (as-contract tx-sender)))

    (map-set campaigns new-id {
      brand-owner: tx-sender,
      name: name,
      total-budget: initial-budget,
      reward-per-mention: reward-per-mention,
      is-active: true
    })
    (var-set campaign-id-counter new-id)
    (ok new-id)
  )
)

;; @desc Allows a brand to deactivate their campaign and reclaim the remaining budget.
;; @param campaign-id: The ID of the campaign to deactivate.
;; @returns (ok bool) or an error.
(define-public (deactivate-campaign (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) ERR_CAMPAIGN_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get brand-owner campaign)) ERR_UNAUTHORIZED)

    ;; Reclaim remaining budget
    (let ((remaining-budget (get total-budget campaign)))
      (if (> remaining-budget u0)
        (try! (as-contract (ft-transfer? reward-points remaining-budget (as-contract tx-sender) (get brand-owner campaign))))
        true
      )
    )

    (map-set campaigns campaign-id (merge campaign { is-active: false, total-budget: u0 }))
    (ok true)
  )
)


;; ---
;; Participant (User) Functions
;; ---

;; @desc Allows a user to claim their pending rewards from a campaign.
;; @param campaign-id: The campaign to claim rewards from.
;; @returns (ok bool) or an error.
(define-public (claim-rewards (campaign-id uint))
  (let
    ((rewards-to-claim (get-user-rewards-for-campaign campaign-id tx-sender)))
    (asserts! (> rewards-to-claim u0) ERR_NO_REWARDS_TO_CLAIM)

    ;; Reset pending rewards for this user and campaign to 0
    (map-delete user-pending-rewards { campaign-id: campaign-id, user: tx-sender })

    ;; Transfer the claimed tokens from the contract to the user
    (try! (as-contract (ft-transfer? reward-points rewards-to-claim (as-contract tx-sender) tx-sender)))

    (ok true)
  )
)


;; ---
;; Read-Only Functions
;; ---

;; @desc Get details for a specific campaign.
(define-read-only (get-campaign-details (campaign-id uint))
  (map-get? campaigns campaign-id)
)

;; @desc Get the pending (unclaimed) rewards for a user for a specific campaign.
(define-read-only (get-user-rewards-for-campaign (campaign-id uint) (user principal))
  (default-to u0 (map-get? user-pending-rewards { campaign-id: campaign-id, user: user }))
)

;; @desc Get the total number of campaigns created.
(define-read-only (get-campaign-count)
  (ok (var-get campaign-id-counter))
)
