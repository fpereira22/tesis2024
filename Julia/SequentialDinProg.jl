using JuMP
import HiGHS
import Test

capacity = 10;
profit = [5, 3, 2, 7, 4];
weight = [2, 8, 4, 2, 5];

@time begin
    model = Model(HiGHS.Optimizer)
    @variable(model, x[1:5], Bin)
    @constraint(model, sum(weight[i] * x[i] for i in 1:5) <= capacity)
    @objective(model, Max, sum(profit[i] * x[i] for i in 1:5))
    print(model)
    optimize!(model)
    solution_summary(model)
    items_chosen = [i for i in 1:5 if value(x[i]) > 0.5]
end

function solve_knapsack_problem(;
    profit,
    weight::Vector{T},
    capacity::T,
) where {T<:Real}
    N = length(weight)

    # The profit and weight vectors must be of equal length.
    @assert length(profit) == N

    model = Model(HiGHS.Optimizer)
    set_silent(model)

    # Declare the decision variables as binary (0 or 1).
    @variable(model, x[1:N], Bin)

    # Objective: maximize profit.
    @objective(model, Max, profit' * x)

    # Constraint: can carry all items.
    @constraint(model, weight' * x <= capacity)

    # Solve problem using MIP solver
    optimize!(model)
    println("Objective is: ", objective_value(model))
    println("Solution is:")
    for i in 1:N
        print("x[$i] = ", Int(value(x[i])))
        println(", c[$i]/w[$i] = ", profit[i] / weight[i])
    end
    Test.@test termination_status(model) == OPTIMAL
    Test.@test primal_status(model) == FEASIBLE_POINT
    Test.@test objective_value(model) == 16.0
    return
end

@time solve_knapsack_problem(; profit = profit, weight = weight, capacity = capacity)
