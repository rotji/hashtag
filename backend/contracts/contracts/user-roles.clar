;; user-roles.clar
;;
;; This contract serves as a central registry for user roles within the application.
;; It allows an admin to assign roles ('admin', 'brand', 'participant') to user principals.
;; Other contracts can then query this contract to check permissions.

;; ---
;; Constants and Errors
;; ---
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u201)) ;; Error for unauthorized access.
(define-constant ERR_INVALID_ROLE (err u202)) ;; Error for assigning an invalid role.

;; ---
;; Data Storage
;; ---

;; A map to store the role for each user principal.
;; key: principal
;; value: (string-ascii 12) - e.g., "admin", "brand", "participant"
(define-map roles principal (string-ascii 12))

;; ---
;; Public Functions
;; ---

;; @desc Assigns a role to a user.
;; @desc Can only be called by the CONTRACT_OWNER (the initial admin).
;; @param user: The principal of the user to assign a role to.
;; @param role: The role to assign. Must be "admin", "brand", or "participant".
;; @returns (ok bool) or an error.
(define-public (set-role (user principal) (new-role (string-ascii 12)))
  (begin
    ;; Ensure only the contract owner can set roles
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)

    ;; Ensure the role is one of the valid types
    (asserts! (or (is-eq new-role "admin") (or (is-eq new-role "brand") (is-eq new-role "participant"))) ERR_INVALID_ROLE)

    ;; Set the role in the map
    (map-set roles user new-role)
    (ok true)
  )
)


;; ---
;; Read-Only Functions
;; ---

;; @desc Retrieves the role for a given user.
;; @param user: The principal of the user to check.
;; @returns (response (string-ascii 12) "none") - The user's role, or "participant" if none is set.
(define-read-only (get-role (user principal))
  ;; If a user does not have a role, they are considered a "participant".
  (ok (default-to "participant" (map-get? roles user)))
)
