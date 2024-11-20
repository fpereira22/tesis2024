using Distributed
addprocs(4)  # Add 4 worker processes

@everywhere using JuMP
@everywhere import HiGHS
@everywhere import Test

@everywhere function solve_knapsack_brute_force(;
    profit,
    weight::Vector{T},
    capacity::T,
) where {T<:Real}
    N = length(weight)

    # The profit and weight vectors must be of equal length.
    @assert length(profit) == N

    # Initialize best solution variables.
    best_obj = 0.0
    best_items = nothing

    # Try all possible combinations of items.
    for i in 0:2^N-1
        items = [j for j in 1:N if i & (1<<j-1) != 0]

        # Check if current combination satisfies capacity constraint.
        if sum(weight[j] for j in items) <= capacity
            obj = sum(profit[j] for j in items)

            # Update best solution if current combination is better.
            if obj > best_obj
                best_obj = obj
                best_items = items
            end
        end
    end

    # Print best solution.
    println("Objective is: ", best_obj)
    println("Solution is:")
    for i in 1:N
        if i in best_items
            print("x[$i] = 1")
        else
            print("x[$i] = 0")
        end
        println(", c[$i]/w[$i] = ", profit[i] / weight[i])
    end
    return
end

@time @sync @distributed for i in 1:4
    solve_knapsack_brute_force(profit=profit, weight=weight, capacity=capacity)
end
