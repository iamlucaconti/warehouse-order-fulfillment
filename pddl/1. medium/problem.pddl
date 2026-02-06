(define (problem warehouse)
  (:domain warehouse)

  (:objects
    r1 - robot

    ;; 4x4 grid locations
    l11 l12 l13 l14
    l21 l22 l23 l24
    l31 l32 l33 l34
    l41 l42 l43 l44 - location

    shelf1 shelf2 shelf3 - shelf
    station1 - station
    recharge1 - recharge-station

    itemA itemB itemC itemD itemE - item
    order1 order2 order3 - order
  )

  (:init
    ;; -------- robot --------
    (at r1 l11)
    (= (load r1) 0)
    (= (capacity r1) 10)            ;; kg

    ;; -------- grid connectivity 4x4 --------
    ;; row 1
    (adj l11 l12) (adj l12 l11)
    (adj l12 l13) (adj l13 l12)
    (adj l13 l14) (adj l14 l13)

    ;; row 2
    (adj l21 l22) (adj l22 l21)
    (adj l22 l23) (adj l23 l22)
    (adj l23 l24) (adj l24 l23)

    ;; row 3
    (adj l31 l32) (adj l32 l31)
    (adj l32 l33) (adj l33 l32)
    (adj l33 l34) (adj l34 l33)

    ;; row 4
    (adj l41 l42) (adj l42 l41)
    (adj l42 l43) (adj l43 l42)
    (adj l43 l44) (adj l44 l43)

    ;; columns
    (adj l11 l21) (adj l21 l11)
    (adj l12 l22) (adj l22 l12)
    (adj l13 l23) (adj l23 l13)
    (adj l14 l24) (adj l24 l14)

    (adj l21 l31) (adj l31 l21)
    (adj l22 l32) (adj l32 l22)
    (adj l23 l33) (adj l33 l23)
    (adj l24 l34) (adj l34 l24)

    (adj l31 l41) (adj l41 l31)
    (adj l32 l42) (adj l42 l32)
    (adj l33 l43) (adj l43 l33)
    (adj l34 l44) (adj l44 l34)

    ;; -------- shelves, station, recharge-station --------
    (shelf-at shelf1 l23)
    (shelf-at shelf2 l42)
    (shelf-at shelf3 l43)

    (station-at station1 l11)
    (recharge-station-at recharge1 l14)

    ;; -------- items --------
    (item-at itemA shelf1)
    (item-at itemB shelf2)
    (item-at itemC shelf2)
    (item-at itemD shelf2)
    (item-at itemE shelf3)

    ;; -------- item weights in kg --------
    (= (weight itemA) 7)
    (= (weight itemB) 4)
    (= (weight itemC) 6)
    (= (weight itemD) 1)
    (= (weight itemE) 5)

    ;; -------- orders --------
    (order-requires order1 itemA)
    (order-requires order1 itemB)
    (pending order1 itemA)
    (pending order1 itemB)

    (order-requires order2 itemC)
    (pending order2 itemC)

    (order-requires order3 itemD)
    (order-requires order3 itemE)
    (pending order3 itemD)
    (pending order3 itemE)

    ;; -------- cost --------
    (= (total-cost) 0)
  )

  (:goal
    (and
      ;; order1
      (item-dropped-off order1 itemA)
      (item-dropped-off order1 itemB)
      (order-completed order1)

      ;; order2
      (item-dropped-off order2 itemC)
      (order-completed order2)

      ;; order3
      (item-dropped-off order3 itemD)
      (item-dropped-off order3 itemE)
      (order-completed order3)
    )
  )

  (:metric minimize (total-cost))
)

