;; ---------------------------------------------------------
;; Participation Noise Reducer
;; Filters low-signal burst activity
;; ---------------------------------------------------------

;; -----------------------------
;; Error codes
;; -----------------------------

(define-constant ERR-TOO-NOISY u400)

;; -----------------------------
;; Configuration constants
;; -----------------------------

(define-constant NOISE-WINDOW u144)        ;; ~1 day
(define-constant MAX-ACTIONS-IN-WINDOW u3)

(define-constant NOISE-PENALTY u1)
(define-constant SIGNAL-REWARD u1)

;; -----------------------------
;; Data storage
;; -----------------------------

;; Last action block
(define-map last-action-block
  principal
  uint
)

;; Action counter within window
(define-map window-action-count
  principal
  uint
)

;; Noise-adjusted participation score
(define-map participation-score
  principal
  uint
)

;; -----------------------------
;; Read-only helpers
;; -----------------------------

(define-read-only (get-score (user principal))
  (default-to u0 (map-get? participation-score user))
)

(define-read-only (get-action-count (user principal))
  (default-to u0 (map-get? window-action-count user))
)

;; -----------------------------
;; Core logic
;; -----------------------------

(define-public (record-participation)
  (let (
        (user tx-sender)
        (last-action (map-get? last-action-block tx-sender))
        (current-score (default-to u0 (map-get? participation-score tx-sender)))
       )

    ;; First interaction
    (if (is-none last-action)
        (begin
          (map-set last-action-block user burn-block-height)
          (map-set window-action-count user u1)
          (map-set participation-score user u1)
          (ok u1)
        )

        ;; Returning user
        (let (
              (previous-block (unwrap-panic last-action))
              (gap (- burn-block-height previous-block))
              (current-count (default-to u0 (map-get? window-action-count user)))
             )

          ;; Outside noise window - reset counter, reward signal
          (if (> gap NOISE-WINDOW)
              (let ((new-score (+ current-score SIGNAL-REWARD)))
                (map-set window-action-count user u1)
                (map-set participation-score user new-score)
                (map-set last-action-block user burn-block-height)
                (ok new-score)
              )

              ;; Inside noise window
              (let ((new-count (+ current-count u1)))
                (map-set last-action-block user burn-block-height)

                ;; Too noisy - penalize
                (if (> new-count MAX-ACTIONS-IN-WINDOW)
                    (let (
                          (penalized-score
                            (if (> current-score NOISE-PENALTY)
                                (- current-score NOISE-PENALTY)
                                u0
                            )
                          )
                         )
                      (map-set participation-score user penalized-score)
                      (err ERR-TOO-NOISY)
                    )

                    ;; Acceptable activity - neutral pass
                    (begin
                      (map-set participation-score user current-score)
                      (ok current-score)
                    )
                )
              )
          )
        )
    )
  )
)
