;; CharityDistributor Contract

;; Define data variables
(define-map verified-charities principal { name: (string-ascii 64), active: bool })
(define-data-var charity-count uint u0)

;; Define public functions
(define-public (add-charity (charity principal) (name (string-ascii 64)))
  (begin
    (asserts! (is-eq tx-sender (contract-caller)) (err u403))
    (map-set verified-charities charity { name: name, active: true })
    (var-set charity-count (+ (var-get charity-count) u1))
    (ok true)
  )
)

(define-public (remove-charity (charity principal))
  (begin
    (asserts! (is-eq tx-sender (contract-caller)) (err u403))
    (map-delete verified-charities charity)
    (var-set charity-count (- (var-get charity-count) u1))
    (ok true)
  )
)

(define-public (distribute-funds (charity principal) (amount uint))
  (let
    ((charity-info (unwrap! (map-get? verified-charities charity) (err u404))))
    (asserts! (get active charity-info) (err u403))
    (asserts! (is-eq tx-sender (contract-caller)) (err u403))
    (as-contract (stx-transfer? amount tx-sender charity))
  )
)

;; Define read-only functions
(define-read-only (is-verified-charity (charity principal))
  (match (map-get? verified-charities charity)
    charity-info (ok (get active charity-info))
    (ok false)
  )
)

(define-read-only (get-charity-count)
  (ok (var-get charity-count))
)

(define-read-only (get-charity-info (charity principal))
  (ok (map-get? verified-charities charity))
)

