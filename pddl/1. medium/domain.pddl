(define (domain warehouse)
  (:requirements
    :strips
    :typing
    :negative-preconditions
    :numeric-fluents
    :action-costs
    :quantified-preconditions
  )

  (:types
    robot
    location
    shelf
    station
    item
    order 
    recharge-station
  )

  (:predicates
    ;; ---- robot and map ----
    (at ?r - robot ?l - location)
    (adj ?l1 - location ?l2 - location)

    ;; ---- shelves and stations ----
    (shelf-at ?s - shelf ?l - location)
    (station-at ?st - station ?l - location)
    (recharge-station-at ?rs - recharge-station ?l - location)

    ;; ---- items ----
    (item-at ?i - item ?s - shelf)
    (carrying ?r - robot ?i - item)

    ;; ---- orders ----
    (order-requires ?o - order ?i - item)
    (pending ?o - order ?i - item)
    (item-dropped-off ?o - order ?i - item)
    (order-completed ?o - order)
  )

  (:functions
    (load ?r - robot)
    (capacity ?r - robot)
    (weight ?i - item)
    (total-cost)
  )

 ;; ---- Move ----
 (:action move
   :parameters (?r - robot ?from - location ?to - location)
   :precondition (and
     (at ?r ?from)
     (adj ?from ?to)
   )
   :effect (and
     (not (at ?r ?from))
     (at ?r ?to)

     ;; cost: base + load factor
     (increase (total-cost) 1)
     (increase (total-cost) (/ (load ?r) 2))
   ) 
 )


  ;; ---- Pick item ----
  (:action pick
    :parameters (?r - robot ?i - item ?s - shelf ?l - location)
    :precondition (and
      (at ?r ?l)
      (shelf-at ?s ?l)
      (item-at ?i ?s)
      (<= (+ (load ?r) (weight ?i)) (capacity ?r))
    )
    :effect (and
      (carrying ?r ?i)
      (not (item-at ?i ?s))
      (increase (load ?r) (weight ?i))
      (increase (total-cost) 1)
    )
  )

  ;; ---- drop-off item ----
  (:action drop-off
    :parameters (?r - robot ?i - item ?o - order ?st - station ?l - location)
    :precondition (and
      (at ?r ?l)
      (station-at ?st ?l)
      (carrying ?r ?i)
      (order-requires ?o ?i)
      (pending ?o ?i)
    )
    :effect (and
      (item-dropped-off ?o ?i)
      (not (pending ?o ?i))
      (not (carrying ?r ?i))
      (decrease (load ?r) (weight ?i))
      (increase (total-cost) 1)
    )
  )

;; ---- Complete order ----
  (:action complete-order
    :parameters (?r - robot ?o - order ?st - station ?l - location)
    :precondition (and
      (not (order-completed ?o))
      (forall (?i - item)
        (not (pending ?o ?i))
      )
      ;; robot must be in the station
      (at ?r ?l)
      (station-at ?st ?l)
    )
    :effect (and
      (order-completed ?o)
      (increase (total-cost) 1)
    )
  )
)

