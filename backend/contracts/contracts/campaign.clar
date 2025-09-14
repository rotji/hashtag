;; comprehensive-campaign-contract.clar
;;
;; This contract manages brand campaigns and rewards users with a fungible token
;; for social media mentions, designed to be updated by a trusted off-chain oracle.

;; ---
;; Traits for Contract Dependencies
;; ---

;; Trait for the user-roles contract.
;; This ensures that any contract implementing this trait has a `get-role` function.
(define-trait user-roles-trait
  (
    (get-role (principal) (response (string-ascii 12) uint))
  )
)

;; Trait for the oracle-registry contract.
;; This ensures that any contract implementing this trait has an `is-oracle` function.
(define-trait oracle-registry-trait
  (
    (is-oracle (principal) (response bool uint))
  )
)

;; ---
;; Constants & Errors
;; ---
(define-constant CONTRACT_OWNER tx-sender)

;; Error Codes
(define-constant ERR_UNAUTHORIZED (err u101)) ;; User is not authorized to perform the action.
(define-constant ERR_CAMPAIGN_NOT_FOUND (err u102)) ;; The specified campaign does not exist.
(define-constant ERR_CAMPAIGN_INACTIVE (err u103)) ;; The campaign is not currently active.
(define-constant ERR_INSUFFICIENT_BUDGET (err u104)) ;; The campaign does not have enough funds.
(define-constant ERR_NO_REWARDS_TO_CLAIM (err u105)) ;; The user has no rewards to claim.


;; ---
;; Fungible Token for Rewards
;; ---
;; Defines the fungible token that will be used for campaign rewards.
(define-fungible-token reward-points)


;; ---
;; Data Storage
;; ---
;; A counter to keep track of the number of campaigns created.
(define-data-var campaign-id-counter uint u0)

;; A map to store the details of each campaign.
(define-map campaigns uint {
  brand-owner: principal,
  name: (string-ascii 64),
  total-budget: uint,
  reward-per-mention: uint,
  is-active: bool
})

;; A map to store the pending rewards for each user in a campaign.
(define-map user-pending-rewards { campaign-id: uint, user: principal } uint)


;; ---
;; Oracle Function
;; ---
;;; Awards a user for a social media mention.
;;; This function can only be called by a trusted oracle. It credits a user with rewards
;;; for a specific campaign, drawing from the campaign's budget.
;;;
;;; @param campaign-id {uint} The ID of the campaign to which the mention belongs.
;;; @param user {principal} The principal of the user who made the social media mention.
;;; @returns (response bool uint) Returns (ok true) on success, or an error if the oracle is
;;; unauthorized, the campaign is not found, inactive, or has an insufficient budget.
(define-public (award-mention (campaign-id uint) (user principal))
  (begin
    ;; PERMISSION CHECK: Ensure the caller is a registered oracle
    (asserts! (unwrap! (contract-call? .oracle-registry is-oracle tx-sender) ERR_UNAUTHORIZED) ERR_UNAUTHORIZED)

    (let
      ((campaign (unwrap! (map-get? campaigns campaign-id) ERR_CAMPAIGN_NOT_FOUND))
       (reward-amount (get reward-per-mention campaign))
       (current-pending-rewards (get-user-rewards-for-campaign campaign-id user)))

      ;; Ensure the campaign is active and has enough budget.
      (asserts! (get is-active campaign) ERR_CAMPAIGN_INACTIVE)
      (asserts! (>= (get total-budget campaign) reward-amount) ERR_INSUFFICIENT_BUDGET)

      ;; Decrease the campaign's budget.
      (map-set campaigns campaign-id
        (merge campaign { total-budget: (- (get total-budget campaign) reward-amount) }))

      ;; Increase the user's pending rewards.
      (map-set user-pending-rewards { campaign-id: campaign-id, user: user }
        (+ current-pending-rewards reward-amount))

      (ok true)
    )
  )
)


;; ---
;; Brand Functions
;; ---
;;; Creates a new campaign.
;;; This function can only be called by a user with the "brand" role. It initializes a new
;;; campaign with a specified budget and reward structure.
;;;
;;; @param name {string-ascii 64} The name of the campaign.
;;; @param initial-budget {uint} The total budget for the campaign, provided in reward-points.
;;; @param reward-per-mention {uint} The amount of reward-points to be awarded for each mention.
;;; @returns (response uint uint) Returns (ok new-id) with the ID of the newly created campaign on success,
;;; or an error if the user is not authorized.
(define-public (create-campaign (name (string-ascii 64)) (initial-budget uint) (reward-per-mention uint))
  (begin
    ;; PERMISSION CHECK: Ensure the caller has the "brand" role
    (let ((role (unwrap! (contract-call? .user-roles get-role tx-sender) ERR_UNAUTHORIZED)))
      (asserts! (is-eq role "brand") ERR_UNAUTHORIZED)
    )

    (let ((new-id (+ (var-get campaign-id-counter) u1)))
      ;; Transfer the initial budget from the brand to the contract.
      (try! (ft-transfer? reward-points initial-budget tx-sender (as-contract tx-sender)))

      ;; Create the new campaign.
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
)

;;; Deactivates a campaign and refunds the remaining budget.
;;; This function can only be called by the brand owner of the campaign. It deactivates the campaign
;;; and refunds any remaining budget to the brand owner.
;;;
;;; @param campaign-id {uint} The ID of the campaign to deactivate.
;;; @returns (response bool uint) Returns (ok true) on success, or an error if the campaign is not found
;;; or the user is not the brand owner.
(define-public (deactivate-campaign (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) ERR_CAMPAIGN_NOT_FOUND)))
    ;; PERMISSION CHECK: Ensure the caller is the brand owner.
    (asserts! (is-eq tx-sender (get brand-owner campaign)) ERR_UNAUTHORIZED)

    (let ((remaining-budget (get total-budget campaign)))
      ;; If there is a remaining budget, transfer it back to the brand owner.
      (if (> remaining-budget u0)
        (try! (as-contract (ft-transfer? reward-points remaining-budget (as-contract tx-sender) (get brand-owner campaign))))
        true
      )
    )

    ;; Deactivate the campaign.
    (map-set campaigns campaign-id (merge campaign { is-active: false, total-budget: u0 }))
    (ok true)
  )
)


;; ---
;; User Functions
;; ---
;;; Claims pending rewards for a campaign.
;;; Allows a user to claim their accumulated rewards for a specific campaign.
;;;
;;; @param campaign-id {uint} The ID of the campaign for which to claim rewards.
;;; @returns (response bool uint) Returns (ok true) on success, or an error if the user has no rewards to claim.
(define-public (claim-rewards (campaign-id uint))
  (let
    ((rewards-to-claim (get-user-rewards-for-campaign campaign-id tx-sender)))
    ;; Ensure the user has rewards to claim.
    (asserts! (> rewards-to-claim u0) ERR_NO_REWARDS_TO_CLAIM)

    ;; Remove the user's pending rewards.
    (map-delete user-pending-rewards { campaign-id: campaign-id, user: tx-sender })

    ;; Transfer the rewards to the user.
    (try! (as-contract (ft-transfer? reward-points rewards-to-claim (as-contract tx-sender) tx-sender)))

    (ok true)
  )
)


;; ---
;; Read-Only Functions
;; ---
;;; Retrieves the details of a campaign.
;;;
;;; @param campaign-id {uint} The ID of the campaign to retrieve.
;;; @returns (response (optional { brand-owner: principal, name: (string-ascii 64), total-budget: uint, reward-per-mention: uint, is-active: bool }) uint)
;;; Returns the campaign details if found, otherwise none.
(define-read-only (get-campaign-details (campaign-id uint))
  (map-get? campaigns campaign-id)
)

;;; Retrieves the pending rewards for a user in a campaign.
;;;
;;; @param campaign-id {uint} The ID of the campaign.
;;; @param user {principal} The principal of the user.
;;; @returns {uint} The amount of pending rewards for the user in the specified campaign. Defaults to u0 if none.
(define-read-only (get-user-rewards-for-campaign (campaign-id uint) (user principal))
  (default-to u0 (map-get? user-pending-rewards { campaign-id: campaign-id, user: user }))
)

;;; Retrieves the total number of campaigns created.
;;;
;;; @returns (response uint uint) Returns (ok campaign-id-counter) with the total number of campaigns.
(define-read-only (get-campaign-count)
  (ok (var-get campaign-id-counter))
)
