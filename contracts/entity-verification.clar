;; Entity Verification Contract
;; Validates participating organizations in the innovation management system

(define-data-var admin principal tx-sender)

;; Data map for registered entities
(define-map registered-entities
  principal
  {
    name: (string-utf8 100),
    industry: (string-utf8 50),
    verified: bool,
    registration-time: uint
  }
)

;; Public function to register a new entity
(define-public (register-entity (name (string-utf8 100)) (industry (string-utf8 50)))
  (let
    ((caller tx-sender))
    (asserts! (not (is-entity-registered caller)) (err u1001))
    (ok (map-set registered-entities
      caller
      {
        name: name,
        industry: industry,
        verified: false,
        registration-time: block-height
      }
    ))
  )
)

;; Admin function to verify an entity
(define-public (verify-entity (entity principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1002))
    (asserts! (is-entity-registered entity) (err u1003))
    (asserts! (not (get verified (unwrap-panic (map-get? registered-entities entity)))) (err u1004))
    (ok (map-set registered-entities
      entity
      (merge (unwrap-panic (map-get? registered-entities entity)) { verified: true })
    ))
  )
)

;; Read-only function to check if an entity is registered
(define-read-only (is-entity-registered (entity principal))
  (is-some (map-get? registered-entities entity))
)

;; Read-only function to check if an entity is verified
(define-read-only (is-entity-verified (entity principal))
  (if (is-entity-registered entity)
    (get verified (unwrap-panic (map-get? registered-entities entity)))
    false
  )
)

;; Read-only function to get entity details
(define-read-only (get-entity-details (entity principal))
  (map-get? registered-entities entity)
)

;; Function to transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u1005))
    (ok (var-set admin new-admin))
  )
)
