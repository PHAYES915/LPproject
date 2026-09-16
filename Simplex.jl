module Simplex

function Solve_lp(D)
    simplex_algorithm(D)
    println("The optimal solution is:$(D.objective_value)")
    println("With decision variables:")
    for i in eachindex(D.basic_variables)
        println("  $(D.basic_variables[i]) = $(D.b[i])")
    end
end

function check_optimality(D)
    for i in eachindex(D.c)
        if D.c[i] < 0
            return false
        end
    end
    return true
end


function simplex_algorithm(D)
    pivot_count = 0
    max_pivots = 100000
    r = check_optimality(D)
    while r == false
      #  println("The current solution is not optimal.")
    simplex_pivot(D)
    r = check_optimality(D) 
    pivot_count += 1
    println("$pivot_count pivots have been attempted")
         if pivot_count < max_pivots
            continue
        else
            print("Algorithm has exceeded maximum pivot count")
            break
        end
    end
end   


function simplex_pivot(D)
    @assert length(D.c) == size(D.A, 2)
    @assert length(D.c) == length(D.nonbasic_variables)

    @assert length(D.b) == size(D.A, 1)
    @assert length(D.b) == length(D.basic_variables)
    entering_variable = nothing
    for i in eachindex(D.c)
        if D.c[i] < 0
            entering_variable = i
            break
        end
    end
    ratios = Float64[]
    for i in axes(D.A, 1)
        if D.A[i, entering_variable] > 0
            push!(ratios, D.b[i] / D.A[i, entering_variable])
        else
            push!(ratios, Inf)  
        end
    end
    if all(isinf, ratios)
    error("No leaving variable: LP is unbounded if the current basis is feasible.")
    end
    leaving_row = argmin(ratios)
    pivot = D.A[leaving_row, entering_variable]
    objective_multiplier = D.c[entering_variable]
    
    D.A[leaving_row, :] /= pivot
    D.b[leaving_row] /= pivot
    D.c -= objective_multiplier * D.A[leaving_row, :]
    D.objective_value -= objective_multiplier * D.b[leaving_row]
    D.c[entering_variable] = -objective_multiplier / pivot  # FIX

    for i in axes(D.A, 1)
        if i != leaving_row
            multiplier = D.A[i, entering_variable]
            D.A[i, :] -= multiplier * D.A[leaving_row, :]
            D.b[i] -= multiplier * D.b[leaving_row]
            D.A[i, entering_variable] = -multiplier / pivot  # FIX

        end
    end
    D.A[leaving_row, entering_variable] = 1 / pivot  # FIX
    D.basic_variables[leaving_row], D.nonbasic_variables[entering_variable] = D.nonbasic_variables[entering_variable], D.basic_variables[leaving_row]
return D
end



end # module Simplex