;; oracle-registry.clar
;;
;; This contract manages a list of trusted oracle principals.
;; The contract owner can add or remove oracles from the list.
;; Other contracts can query this registry to verify if a caller is an authorized oracle.

;; ---
;; Constants and Errors
;; ---
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u301)) ;; Error for unauthorized access.

;; ---
;; Data Storage
;; ---

;; A map to store trusted oracle principals.
;; Using a map as a set: the key is the oracle's principal, the value is always true.
(define-map oracles principal bool)


;; ---
;; Admin Functions
;; ---

;;; Adds a new principal to the list of trusted oracles.
;;; Can only be called by the CONTRACT_OWNER.
;;;
;;; @param new-oracle {principal} The principal of the oracle to add.
;;; @returns (response bool uint) Returns (ok true) on success, or an error if the caller is not authorized.
(define-public (add-oracle (new-oracle principal))
  (begin
    ;; Ensure the caller is the contract owner.
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    ;; Add the new oracle to the map.
    (map-set oracles new-oracle true)
    (ok true)
  )
)

;;; Removes a principal from the list of trusted oracles.
;;; Can only be called by the CONTRACT_OWNER.
;;;
;;; @param oracle-to-remove {principal} The principal of the oracle to remove.
;;; @returns (response bool uint) Returns (ok true) on success, or an error if the caller is not authorized.
(define-public (remove-oracle (oracle-to-remove principal))
  (begin
    ;; Ensure the caller is the contract owner.
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    ;; Remove the oracle from the map.
    (map-delete oracles oracle-to-remove)
    (ok true)
  )
)


;; ---
;; Read-Only Functions
;; ---

;;; Checks if a given principal is a registered oracle.
;;;
;;; @param who {principal} The principal to check.
;;; @returns (response bool uint) Returns (ok true) if the principal is a trusted oracle, (ok false) otherwise.
(define-read-only (is-oracle (who principal))
  ;; Returns true if the principal is in the oracles map, false otherwise.
  (ok (is-some (map-get? oracles who)))
)
