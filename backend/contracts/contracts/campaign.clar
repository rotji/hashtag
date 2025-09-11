;; comprehensive-campaign-contract.clar
;;
;; This contract manages brand campaigns and rewards users with a fungible token
;; for social media mentions, designed to be updated by a trusted off-chain oracle.

;; ---
;; Constants & Errors
;; ---
(define-constant CONTRACT_OWNER tx-sender)
;; This should be updated to use the oracle-registry contract in a future step.
(define-constant ORACLE_PRINCIPAL tx-sender)

;; Error Codes
(define-constant ERR_UNAUTHORIZED (err u101))
(define-constant ERR_CAMPAIGN_NOT_FOUND (err u102))
(define-constant ERR_CAMPAIGN_INACTIVE (err u103))
(define-constant ERR_INSUFFICIENT_BUDGET (err u104))
(define-constant ERR_NO_REWARDS_TO_CLAIM (err u105))


;; ---
;; Fungible Token for Rewards
;; ---
(define-fungible-token reward-points)


;; ---
;; Data Storage
;; ---
(define-data-var campaign-id-counter uint u0)

(define-map campaigns uint {
  brand-owner: principal,
  name: (string-ascii 64),
  total-budget: uint,
  reward-per-mention: uint,
  is-active: bool
})

(define-map user-pending-rewards { campaign-id: uint, user: principal } uint)


;; ---
;; Oracle Function
;; ---
(define-public (award-mention (campaign-id uint) (user principal))
  (begin
    (asserts! (is-eq tx-sender ORACLE_PRINCIPAL) ERR_UNAUTHORIZED)

    (let
      ((campaign (unwrap! (map-get? campaigns campaign-id) ERR_CAMPAIGN_NOT_FOUND))
       (reward-amount (get reward-per-mention campaign))
       (current-pending-rewards (get-user-rewards-for-campaign campaign-id user)))

      (asserts! (get is-active campaign) ERR_CAMPAIGN_INACTIVE)
      (asserts! (>= (get total-budget campaign) reward-amount) ERR_INSUFFICIENT_BUDGET)

      (map-set campaigns campaign-id
        (merge campaign { total-budget: (- (get total-budget campaign) reward-amount) }))

      (map-set user-pending-rewards { campaign-id: campaign-id, user: user }
        (+ current-pending-rewards reward-amount))

      (ok true)
    )
  )
)


;; ---
;; Brand Functions
;; ---
(define-public (create-campaign (name (string-ascii 64)) (initial-budget uint) (reward-per-mention uint))
  (let ((new-id (+ (var-get campaign-id-counter) u1)))
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

(define-public (deactivate-campaign (campaign-id uint))
  (let ((campaign (unwrap! (map-get? campaigns campaign-id) ERR_CAMPAIGN_NOT_FOUND)))
    (asserts! (is-eq tx-sender (get brand-owner campaign)) ERR_UNAUTHORIZED)

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
;; User Functions
;; ---
(define-public (claim-rewards (campaign-id uint))
  (let
    ((rewards-to-claim (get-user-rewards-for-campaign campaign-id tx-sender)))
    (asserts! (> rewards-to-claim u0) ERR_NO_REWARDS_TO_CLAIM)

    (map-delete user-pending-rewards { campaign-id: campaign-id, user: tx-sender })

    (try! (as-contract (ft-transfer? reward-points rewards-to-claim (as-contract tx-sender) tx-sender)))

    (ok true)
  )
)


;; ---
;; Read-Only Functions
;; ---
(define-read-only (get-campaign-details (campaign-id uint))
  (map-get? campaigns campaign-id)
)

(define-read-only (get-user-rewards-for-campaign (campaign-id uint) (user principal))
  (default-to u0 (map-get? user-pending-rewards { campaign-id: campaign-id, user: user }))
)

(define-read-only (get-campaign-count)
  (ok (var-get campaign-id-counter))
)
