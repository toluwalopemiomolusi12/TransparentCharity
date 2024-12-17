;; CharityRating Contract

;; Define data variables
(define-map charity-ratings principal { rating: uint, total-votes: uint })
(define-map user-votes { user: principal, charity: principal } { rating: uint })

;; Define constants
(define-constant MAX_RATING u5)

;; Define public functions
(define-public (rate-charity (charity principal) (rating uint))
  (let
    (
      (user tx-sender)
      (current-vote (get rating (default-to { rating: u0 } (map-get? user-votes { user: user, charity: charity }))))
      (current-rating (default-to { rating: u0, total-votes: u0 } (map-get? charity-ratings charity)))
    )
    (asserts! (<= rating MAX_RATING) (err u400))
    (asserts! (not (is-eq current-vote rating)) (err u401))
    
    (map-set charity-ratings charity
      (merge current-rating
        {
          rating: (if (is-eq current-vote u0)
                    (+ (get rating current-rating) rating)
                    (+ (- (get rating current-rating) current-vote) rating)),
          total-votes: (if (is-eq current-vote u0)
                         (+ (get total-votes current-rating) u1)
                         (get total-votes current-rating))
        }
      )
    )
    
    (map-set user-votes { user: user, charity: charity } { rating: rating })
    (ok true)
  )
)

;; Define read-only functions
(define-read-only (get-charity-rating (charity principal))
  (let
    ((rating-info (default-to { rating: u0, total-votes: u0 } (map-get? charity-ratings charity))))
    (if (is-eq (get total-votes rating-info) u0)
      (ok u0)
      (ok (/ (get rating rating-info) (get total-votes rating-info)))
    )
  )
)

(define-read-only (get-user-vote (user principal) (charity principal))
  (ok (get rating (default-to { rating: u0 } (map-get? user-votes { user: user, charity: charity }))))
)

