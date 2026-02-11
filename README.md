# Warehouse-order-fulfillment

# Domain description
The selected domain is **warehouse order fulfillment**, a realistic logistics scenario inspired by automated warehouse systems used by large-scale retail companies.

A single mobile robot operates within a warehouse composed of storage shelves, packing stations, and recharge stations. The robot is responsible for picking items from shelves, transporting them across the warehouse, and assembling customer orders at packing stations.

# PDDL-based planning

We model the problem using PDDL and consider a single robot. The objective is to determine whether the robot can complete all pending orders given its initial position, the spatial distribution of items, a limited carrying capacity and a limited battery capacity.

## Problem instances
We define three planning problems of increasing complexity:

- **Easy**: The robot can carry only one item at a time. Each order consists of a single item. The robot has unlimited battery capacity. All actions have unit cost.

- **Medium**: Each order consists of multiple items. Each item has an associated weight. The robot can carry multiple items as long as the maximum load capacity (`capacity`) is not exceeded. The cost of the `move` action depends on the current load being transported. The robot has unlimited battery capacity.

- **Hard**: Each order consists of multiple items, and each item has an associated weight (in kilograms). The robot can carry multiple items as long as the maximum load limit (`capacity`) is respected. The cost of the `move` action depends on the carried load. The robot now has a limited battery capacity (`battery-capacity`) and can recharge at a `recharge-station`. Battery consumption increases with the transported weight. In addition, orders are assigned a priority level (`priority`).


The warehouse grid is 4×4. Each action is associated with a cost, enabling the comparison of alternative strategies and the computation of cost-optimal plans..

## Planners & heuristics
Fast Downward was **not suitable** for our **medium** and **hard** domains due to its limited support for:

- numeric fluents
- quantified preconditions
- complex numeric constraints.

For this reason, we employed **ENHSP**, that supports classic and **numeric planning**. The following planners were used:

- **sat-hadd**: **Greedy Best-First Search** combined with numeric $h^{add}$ ; it provides fast but **sub-optimal** solutions.
- **opt-hmax**: $h^{max}$ paired with the hmax heuristic; since $h^{max}$ is admissible, it guarantees **optimal** solutions. 

To execute the reasoning tasks, navigate to the ENHSP directory and run:
```
java -jar enhsp.jar -o <domain_file> -f <problem_file> -planner opt-hmax
```
You can replace `opt-hmax` with `sat-hadd` depending on whether you need optimality or faster (sub-optimal) solutions.

# Indigolog-based reasoning
The project integrates Indigolog to provide reasoning capabilities beyond classical planning, allowing the system to deal with nondeterminism and exogenous events.

## Controllers available

- `dumb`: A deterministic controller that follows a fixed strategy to reach the goal.
- `smart_search`: A search-based controller.
- `congolog`: A deterministic controller capable of handling exogenous events
- `indigolog`: An extension of the `smart_search` controller that explicitly reasons about exogenous events.



## How to run

To execute the reasoning tasks, clone this repository inside the Indigolog folder and run:
```
swipl config.pl warehouse-order-fulfillment/indigolog/main.pl
```
Then, use the following commands:

- `main.`: Displays available controllers and allows selection.
- `test_legality.`: Solves the legality task defined in `task.pl`.
- `test_projection.`: Solves the projection task.

# Group members
- Luca Conti (student ID: 1702084)
- Riccardo D’Aguanno (student ID: 2172315)
- Francesco Fragale (student ID: 2169937)
