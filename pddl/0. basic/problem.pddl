(define (problem warehouse-easy)
  (:domain warehouse)

  (:objects
    r1 - robot

    ;; 4x4 grid locations
    l11 l12 l13 l14
    l21 l22 l23 l24
    l31 l32 l33 l34
    l41 l42 l43 l44 - location

    shelf1 shelf2 - shelf
    station1 - station

    itemA itemB - item
    order1 order2 - order
  )

  (:init
    ;; robot
    (at r1 l11)
    (handempty r1)
    
    ;; -------- shelves and station --------
    (shelf-at shelf1 l41)
    (shelf-at shelf2 l34)
    (station-at station1 l11)

    ;; -------- items --------
    (item-at itemA shelf1)
    (item-at itemB shelf2)

    ;; -------- orders --------
    (order-requires order1 itemA)
    (order-requires order2 itemB)


    ;; -------- grid connectivity 4x4 --------

    ;; row 1
    (connected l11 l12) (connected l12 l11)
    (connected l12 l13) (connected l13 l12)
    (connected l13 l14) (connected l14 l13)

    ;; row 2
    (connected l21 l22) (connected l22 l21)
    (connected l22 l23) (connected l23 l22)
    (connected l23 l24) (connected l24 l23)

    ;; row 3
    (connected l31 l32) (connected l32 l31)
    (connected l32 l33) (connected l33 l32)
    (connected l33 l34) (connected l34 l33)

    ;; row 4
    (connected l41 l42) (connected l42 l41)
    (connected l42 l43) (connected l43 l42)
    (connected l43 l44) (connected l44 l43)

    ;; columns
    (connected l11 l21) (connected l21 l11)
    (connected l12 l22) (connected l22 l12)
    (connected l13 l23) (connected l23 l13)
    (connected l14 l24) (connected l24 l14)

    (connected l21 l31) (connected l31 l21)
    (connected l22 l32) (connected l32 l22)
    (connected l23 l33) (connected l33 l23)
    (connected l24 l34) (connected l34 l24)

    (connected l31 l41) (connected l41 l31)
    (connected l32 l42) (connected l42 l32)
    (connected l33 l43) (connected l43 l33)
    (connected l34 l44) (connected l44 l34)

    ;; cost
    (= (total-cost) 0)
  )

  (:goal
    (and
      ;; order1 and order2
      (item-delivered order1 itemA)
      (order-delivered order1)

      (item-delivered order2 itemB)
      (order-delivered order2)
    )
  )

  (:metric minimize (total-cost))
)

