%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL DECLARATIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic controller/1.
:- discontiguous
    fun_fluent/1,
    rel_fluent/1,
    proc/2,
    causes_true/3,
    causes_false/3,
    causes_val/4,
    poss/2,
    prim_action/1.

cache(_) :- fail.
actionNum(X, X).

% battery_low
% slip(r1, i3)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOMAIN PARAMETERS (Static)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grid dim
width(3).
height(1).

robot(r1).
% robot maximum capacity (kg)
capacity(r1, 3).

% item_info(ID, InitX, InitY, Weight)
item_info(i1, 1, 0, 1).
item_info(i2, 2, 0, 2).
item_info(i3, 2, 0, 3).

% Helper 
item(I) :- item_info(I, _, _, _).

order(o1).
order(o2).

order_requires(o1, i1).
order_requires(o1, i3).
order_requires(o2, i2).

% delivery station
station(0, 0).

% recharging station
recharge_station(0, 0).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FLUENTS (Dynamic)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fun_fluent(pos_x(R)) :- robot(R).
fun_fluent(pos_y(R)) :- robot(R).
fun_fluent(current_load(R)) :- robot(R).

% Object positions are dynamic
fun_fluent(item_pos_x(I)) :- item(I).
fun_fluent(item_pos_y(I)) :- item(I).

rel_fluent(carrying(R, I)) :- robot(R), item(I).
rel_fluent(order_delivered(O)) :- order(O).
rel_fluent(delivered(I)) :- item(I).

% Battery state
rel_fluent(low_battery).

% Object slipped to the ground
rel_fluent(slipped(I)) :- item(I).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INITIAL CONDITIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initially(pos_x(r1), 0).
initially(pos_y(r1), 0).
initially(current_load(R), 0) :- robot(R).

% Item positions
initially(item_pos_x(I), X) :- item_info(I, X, _, _).
initially(item_pos_y(I), Y) :- item_info(I, _, Y, _).

initially(carrying(R, I), false) :- robot(R), item(I).
initially(delivered(I), false) :- item(I).
initially(order_delivered(O), false) :- order(O).
initially(low_battery, false).
initially(slipped(I), false) :- item(I).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GOAL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc(solved, [
    ?(delivered(i1)),
    ?(delivered(i2)),
    ?(delivered(i3)),
    ?(order_delivered(o1)),
    ?(order_delivered(o2))
]).

prim_action(say(_)).
poss(say(_), true).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIMITIVE ACTIONS: MOVEMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prim_action(up(R)).
poss(up(R), and(robot(R), neg(pos_y(R) = MaxY))) :- height(H), MaxY is H-1.
causes_val(up(R), pos_y(R), N, N is pos_y(R) + 1).

prim_action(down(R)).
poss(down(R), and(robot(R), neg(pos_y(R) = 0))).
causes_val(down(R), pos_y(R), N, N is pos_y(R) - 1).

prim_action(left(R)).
poss(left(R), and(robot(R), neg(pos_x(R) = 0))).
causes_val(left(R), pos_x(R), N, N is pos_x(R) - 1).

prim_action(right(R)).
poss(right(R), and(robot(R), neg(pos_x(R) = MaxX))) :- width(W), MaxX is W-1.
causes_val(right(R), pos_x(R), N, N is pos_x(R) + 1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIMITIVE ACTION: PICK-UP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prim_action(pick_up(R, I, X, Y)).
poss(pick_up(R, I, X, Y),
    and(robot(R),
    and(item_info(I, _, _, W), 
    and(item_pos_x(I) = X,    
    and(item_pos_y(I) = Y,    
    and(pos_x(R) = X,          
    and(pos_y(R) = Y,
    and(neg(delivered(I)),    
    and(capacity(R, C),
        =<(current_load(R) + W, C)))))))))).

causes_true(pick_up(R, I, _, _), carrying(R, I), true).
causes_false(pick_up(R, I, _, _), slipped(I), true). 

causes_val(pick_up(R, I, _, _),
           current_load(R),
           N,
           and(item_info(I, _, _, W),
               N is current_load(R) + W)).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIMITIVE ACTION: DROP-OFF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prim_action(drop_off(R, I, O, XS, YS)).
poss(drop_off(R, I, O, XS, YS),
     and(robot(R),
     and(item(I),
     and(order(O),
     and(order_requires(O, I),
     and(station(XS, YS),
     and(carrying(R, I),    
     and(neg(delivered(I)),
     and(pos_x(R)=XS, pos_y(R)=YS))))))))).

causes_false(drop_off(R, I, _, _, _), carrying(R, I), true).
causes_true(drop_off(R, I, _, _, _), delivered(I), true).
causes_false(drop_off(R, I, _, _, _), slipped(I), true). % Safety reset
causes_val(drop_off(R, I, _, _, _),
           current_load(R),
           N,
           and(item_info(I, _, _, W),
               N is current_load(R) - W)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRIMITIVE ACTION: COMPLETE ORDER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prim_action(complete_order(O)).

poss(complete_order(O), Cond) :-
    order(O),
    findall(delivered(I), order_requires(O, I), L), 
    % Find all items required by the order and build a list of "delivered(I)" conditions
    list_to_and(L, Cond).

list_to_and([], true).
list_to_and([X], X).
list_to_and([X|Xs], and(X, R)) :- list_to_and(Xs, R).

causes_true(complete_order(O), order_delivered(O), true).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RECHARGE BATTERY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
prim_action(recharge).

poss(recharge,
     and(low_battery,
         and(pos_x(r1) = XS,
             and(pos_y(r1) = YS,
                 recharge_station(XS, YS))))).


causes_false(recharge, low_battery, true).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXOGENOUS ACTIONS: BATTERY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exog_action(battery_low).
prim_action(A) :- exog_action(A).
poss(A, true) :- exog_action(A).

causes_true(battery_low, low_battery, true).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXOGENOUS ACTIONS: SLIP 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
exog_action(slip(R, I)) :- robot(R), item(I).
% preconditions
poss(slip(R, I), carrying(R, I)).

% Effects
causes_false(slip(R, I), carrying(R, I), true).
causes_true(slip(R, I), slipped(I), true).
causes_val(slip(R, I), current_load(R), N, 
           and(item_info(I, _, _, W), N is current_load(R) - W)).

causes_val(slip(R, I), item_pos_x(I), X, pos_x(R)=X).
causes_val(slip(R, I), item_pos_y(I), Y, pos_y(R)=Y).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUPPORT PROCEDURES (Pathfinding)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc(step_towards_X(R, DX),
    if(pos_x(R) < DX, right(R),
       if(pos_x(R) > DX, left(R), no_op))
).

proc(step_towards_Y(R, DY),
    if(pos_y(R) < DY, up(R),
       if(pos_y(R) > DY, down(r), no_op))
).

proc(smart_go_to(R, X, Y),
    while(or(neg(pos_x(R) = X), neg(pos_y(R) = Y)),
        [ ndet(step_towards_X(R, X),
               step_towards_Y(R, Y)) ])
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPOSITE ACTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc(actions, [
    ndet(
        ndet(
            ndet(up(r1), down(r1)),
            ndet(left(r1), right(r1))
        ),
        ndet(
            pick_up(r1, I, X, Y),
            ndet(
                drop_off(r1, I, O, XS, YS),
                complete_order(O)
            )
        )
    )
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HANDLING LOW BATTERY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc(handle_low_battery,
    pi(xs, pi(ys, [
        ?(recharge_station(xs, ys)),
        smart_go_to(r1, xs, ys),
        recharge
    ]))
).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HANDLING SLIPPED ITEM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc(handle_slipped_item(I),
    pi(x, pi(y, [
        % find where the item ended up
        ?(item_pos_x(I) = x),
        ?(item_pos_y(I) = y),
        
        % go there
        smart_go_to(r1, x, y),
        
        % pick it up
        pick_up(r1, I, x, y)
    ]))
).


% Standard Service Procedure
% An item is "pending" if it is not delivered and it is not currently "slipped"
proc(pending_item(I), 
    and(item(I), 
    and(neg(delivered(I)),
        neg(slipped(I))))).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTROLLER: DUMB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc(pending_item(I), and(item_info(I, _, _, _), neg(delivered(I)))).

proc(serve_item(I),
    pi(x, pi(y, [
        ?(item_info(I, x, y, _)),
        smart_go_to(r1, x, y),
        pick_up(r1, I, x, y),
        ?(station(XS, YS)),
        smart_go_to(r1, XS, YS),
        pi(o, [
            ?(and(order(O), order_requires(O, I))),
            drop_off(r1, I, O, XS, YS)
        ])
    ]))
).

proc(serve_some_item,
    pi(i, [ ?(pending_item(i)), serve_item(i) ])
).

proc(control(dumb),
   [
     while(some(i, pending_item(i)), serve_some_item),
     complete_order(o1),
     complete_order(o2)
   ]
).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTROLLER: SMART_SEARCH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc(control(smart_search), search(minimize_steps(0))).

proc(minimize_steps(Max),
    ndet(
        solve_in_steps(Max),
        pi(n, [?(n is Max + 1), minimize_steps(n)])
    )
).

proc(solve_in_steps(0), solved).

proc(solve_in_steps(N),
    [ ?(N > 0),
      actions,
      pi(m, [?(m is N - 1), solve_in_steps(m)])
    ]
).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTROLLER: CONGOLOG
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
proc(control(congolog),
  [
    prioritized_interrupts(
      [
        % priority 1: slip handling
        interrupt(some(i, and(slipped(i), neg(delivered(i)))),
          pi(i, [
            ?(and(slipped(i), neg(delivered(i)))),
            handle_slipped_item(i)
          ])
        ),

        % priority 2: low battery
        interrupt(low_battery, handle_low_battery),

        % priority 3: serve items
        interrupt(some(i, pending_item(i)), serve_some_item)
      ]
    ),

    % main loop
    while(some(i, neg(delivered(i))),
      ?(wait_exog_action)
    ),

    % Order completion
    complete_order(o1),
    complete_order(o2)
  ]
).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONTROLLER: INDIGOLOG (REACTIVE + PLANNING)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc(control(indigolog),
  [
    prioritized_interrupts(
      [

        % priority 1: slip handling
        interrupt(
          some(i, and(slipped(i), neg(delivered(i)))),
          pi(i, [
            ?(and(slipped(i), neg(delivered(i)))),
            handle_slipped_item(i)
          ])
        ),

        % priority 2: low battery
        interrupt(
          low_battery,
          handle_low_battery
        ),

        % priority 3: planning
        interrupt(
          or(
            some(i, neg(delivered(i))),
            neg(and(order_delivered(o1), order_delivered(o2)))
          ),
          gexec(
            true,
            search(minimize_steps(0), "Planning to solved")
          )
        )
      ]
    ),

    % the system remains reactive until completion
    while(
      or(
        some(i, neg(delivered(i))),
        neg(and(order_delivered(o1), order_delivered(o2)))
      ),
      ?(wait_exog_action)
    )
  ]
).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LEGALITY 
% indigolog([a1, ..., an]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_legality :-
    writeln('--- START LEGALITY CHECK ---'),
    Actions = [
        right(r1),
        pick_up(r1, i3, 1, 0),
        left(r1),
        drop_off(r1, i3, o1, 0, 0)
    ],
    indigolog(Actions).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PROJECTION TASK
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

test_projection :-
    writeln('--- START PROJECTION CHECK ---'),
    
    History = [
        pick_up(r1, i3, 1, 0),  
        right(r1)               
    ],

    write('Check Carrying: '),
    (   eval(carrying(r1, i3), History, true)
    ->  writeln('OK (True)')
    ;   writeln('FAIL (False)')
    ),


    write('Check Load=3: '),
    (   eval(current_load(r1), History, 3)
    ->  writeln('OK (True)')
    ;   writeln('FAIL')
    ),
    

    write('Check Not Delivered: '),
    (   \+ eval(delivered(i3), History, true)
    ->  writeln('OK (Not delivered)')
    ;   writeln('FAIL')
    ).  
