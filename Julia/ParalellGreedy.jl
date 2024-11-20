using JuMP
using Distributed
import HiGHS
import Test
import Base.Threads

function solve_knapsack_problem_greedy_parallel(;
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

    num_threads = 4
    chunk_size = div(length(order), num_threads)
    results = @sync @distributed (+) for i=1:num_threads
        start_idx = (i-1) * chunk_size + 1
        end_idx = min(i * chunk_size, length(order))
        thread_selected_items = falses(N)
        thread_selected_weight = 0.0
        thread_selected_profit = 0.0
        for j in start_idx:end_idx
            if thread_selected_weight + weight[order[j]] <= capacity
                thread_selected_items[order[j]] = true
                thread_selected_weight += weight[order[j]]
                thread_selected_profit += profit[order[j]]
            else
                break
            end
        end
        (thread_selected_items, thread_selected_weight, thread_selected_profit)
    end

    for (thread_selected_items, thread_selected_weight, thread_selected_profit) in results
        if thread_selected_profit > selected_profit
            selected_items = thread_selected_items
            selected_weight = thread_selected_weight
            selected_profit = thread_selected_profit
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

# Define the input data
capacity = 10
profit = [5, 3, 2, 7, 4]
weight = [2, 8, 4, 2, 5]

# Run the function
@time solve_knapsack_problem_greedy_parallel(profit=profit, weight=weight, capacity=capacity)
