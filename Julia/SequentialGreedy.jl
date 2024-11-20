using JuMP
import HiGHS
import Test

capacity = 10;
profit = [5, 3, 2, 7, 4];
weight = [2, 8, 4, 2, 5];

function solve_knapsack_problem_greedy(;
    profit::Vector{T},
    weight::Vector{T},
    capacity::T,
) where {T<:Real}
    N = length(weight)

    # The profit and weight vectors must be of equal length.
    @assert length(profit) == N

    order = sortperm(profit ./ weight; rev=true)
    selected_items = falses(N)
    selected_weight = 0.0
    selected_profit = 0.0

    for i in order
        if selected_weight + weight[i] <= capacity
            selected_items[i] = true
            selected_weight += weight[i]
            selected_profit += profit[i]
        else
            break
        end
    end

    println("Objective is: ", selected_profit)
    println("Solution is:")
    for i in 1:N
        print("x[$i] = ", Int(selected_items[i]))
        println(", c[$i]/w[$i] = ", profit[i] / weight[i])
    end
    return
end

@time solve_knapsack_problem_greedy(profit=profit, weight=weight, capacity=capacity)
