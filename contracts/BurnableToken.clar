;; Burnable Token Contract
;; A fungible token implementation with burn functionality
;; Allows token holders to permanently destroy their tokens

;; Define the burnable token
(define-fungible-token burnable-token)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-insufficient-balance (err u101))
(define-constant err-invalid-amount (err u102))
(define-constant err-not-token-owner (err u103))

;; Token metadata
(define-data-var token-name (string-ascii 32) "Burnable Token")
(define-data-var token-symbol (string-ascii 10) "BURN")
(define-data-var token-decimals uint u6)

;; Total supply tracking
(define-data-var total-supply uint u1000000) ;; Initial supply of 1,000,000 tokens

;; Initialize contract with tokens minted to owner
(begin
  (ft-mint? burnable-token u1000000 contract-owner))

;; Function 1: Mint new tokens (only contract owner)
;; This function allows the contract owner to create new tokens
(define-public (mint-tokens (amount uint) (recipient principal))
  (begin
    ;; Only contract owner can mint new tokens
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    ;; Amount must be greater than 0
    (asserts! (> amount u0) err-invalid-amount)
    ;; Validate recipient is not null
    (asserts! (is-standard recipient) err-invalid-amount)
    ;; Mint the tokens to recipient
    (try! (ft-mint? burnable-token amount recipient))
    ;; Update total supply
    (var-set total-supply (+ (var-get total-supply) amount))
    ;; Return success
    (ok amount)))

;; Function 2: Burn tokens permanently 
;; This function allows token holders to permanently destroy their tokens
(define-public (burn-tokens (amount uint))
  (begin
    ;; Amount must be greater than 0
    (asserts! (> amount u0) err-invalid-amount)
    ;; Check if sender has sufficient balance
    (asserts! (>= (ft-get-balance burnable-token tx-sender) amount) err-insufficient-balance)
    ;; Burn the tokens from sender's account
    (try! (ft-burn? burnable-token amount tx-sender))
    ;; Update total supply by reducing burned amount
    (var-set total-supply (- (var-get total-supply) amount))
    ;; Return success with burned amount
    (ok amount)))

;; Read-only functions for token information
(define-read-only (get-balance (account principal))
  (ok (ft-get-balance burnable-token account)))

(define-read-only (get-total-supply)
  (ok (var-get total-supply)))

(define-read-only (get-name)
  (ok (var-get token-name)))

(define-read-only (get-symbol)
  (ok (var-get token-symbol)))

(define-read-only (get-decimals)
  (ok (var-get token-decimals)))