;; DonationManager Contract

;; Define data variables
(define-data-var total-donations uint u0)
(define-map donors principal { total-donated: uint, last-donation: uint })

;; Define a variable to store the contract owner
(define-data-var contract-owner principal tx-sender)

;; Define public functions
(define-public (donate (amount uint))
  (let
    (
      (sender tx-sender)
      (current-time (get-block-info? time (- block-height u1)))
    )
    (asserts! (> amount u0) (err u400))
    (try! (stx-transfer? amount sender (as-contract tx-sender)))
    (map-set donors
      sender
      (merge (get-donor-info-or-default sender)
             { total-donated: (+ amount (get total-donated (get-donor-info-or-default sender))),
               last-donation: (unwrap-panic current-time) }
      )
    )
    (var-set total-donations (+ (var-get total-donations) amount))
    (ok true)
  )
)

(define-public (withdraw-donations (recipient principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (asserts! (> amount u0) (err u400))
    (asserts! (<= amount (var-get total-donations)) (err u401))
    (try! (as-contract (stx-transfer? amount tx-sender recipient)))
    (var-set total-donations (- (var-get total-donations) amount))
    (ok true)
  )
)

;; Define read-only functions
(define-read-only (get-total-donations)
  (ok (var-get total-donations))
)

(define-read-only (get-donor-info (donor principal))
  (ok (get-donor-info-or-default donor))
)

;; Define private functions
(define-private (get-donor-info-or-default (donor principal))
  (default-to 
    { total-donated: u0, last-donation: u0 } 
    (map-get? donors donor)
  )
)

;; Define a function to change the contract owner
(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) (err u403))
    (ok (var-set contract-owner new-owner))
  )
)



