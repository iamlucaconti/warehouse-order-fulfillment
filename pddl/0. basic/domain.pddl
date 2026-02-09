(define (domain warehouse)
  (:requirements
    :strips
    :typing
    :negative-preconditions
    :action-costs
  )

  (:types
    robot
    location
    shelf
    station
    item
    order
  )

  (:predicates
    ;; ---- robot and map ----
    (at ?r - robot ?l - location)
    (adj ?l1 - location ?l2 - location)

    ;; ---- shelves and stations ----
    (shelf-at ?s - shelf ?l - location)
    (station-at ?st - station ?l - location)

    ;; ---- items ----
    (item-at ?i - item ?s - shelf)
    (carrying ?r - robot ?i - item)
    (handempty ?r - robot)

    ;; ---- orders ----
    (order-requires ?o - order ?i - item)
    (item-delivered ?o - order ?i - item)
    (order-completed ?o - order)
  )

  (:functions
    (total-cost)
  )


  ;; ----  move ---- 
  (:action move
    :parameters (?r - robot ?from - location ?to - location)
    :precondition (and
      (at ?r ?from)
      (adj ?from ?to)
    )
    :effect (and
      (not (at ?r ?from))
      (at ?r ?to)
      (increase (total-cost) 1)
    )
  )


  ;; ---- pick item  ---- 
  (:action pick
    :parameters (?r - robot ?i - item ?s - shelf ?l - location)
    :precondition (and
      (at ?r ?l)
      (shelf-at ?s ?l)
      (item-at ?i ?s)
      (handempty ?r)
    )
    :effect (and
      (carrying ?r ?i)
      (not (item-at ?i ?s))
      (not (handempty ?r))
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
      (not (item-delivered ?o ?i))
    )
    :effect (and
      (item-delivered ?o ?i)
      (not (carrying ?r ?i))
      (handempty ?r)
      (increase (total-cost) 1)
    )
  )

  ;; ---- complete order ---- 
  (:action complete-order
    :parameters (?o - order ?i - item)
    :precondition (and
      (order-requires ?o ?i)
      (item-delivered ?o ?i)
      (not (order-completed ?o))
    )
    :effect (and
      (order-completed ?o)
    )
  )
)

