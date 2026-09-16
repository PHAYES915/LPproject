include("Simplex.jl")
using .Simplex
 c = []
 x = String[]
 b = Float64[]


 function matrix_create(;n = 0, m = 0)
    A = zeros(n, m)
    for i in 1:n
        for j in 1:m
            A[i, j] = round(2rand() - 1, digits = 3)
        end
    #println("A: $A")
    end
    return A, m, n
 end

 function initialize(;c, b, A, m, n)
    x = fill("", m)
    for i in eachindex(c)
        c[i] = round(2rand() - 1, digits = 3)
    end
    # println("c: $c")
    for i in 1:n
        b[i] = round(rand(), digits = 3)
    end
    # println("b: $b")
    
    for i in 1:m
        x[i] = "x$i"
    end
    # println("x: $x")
    basic_variables = collect(m+1:m+n)
    nonbasic_variables = collect(1:m)
    return A, b, c, x, basic_variables, nonbasic_variables
 end

 function algebraic_lp(;c, b, A, x)
    o = fill("", length(c))
    for i in eachindex(c)
        o[i] = "$c[i]$x[i]"
    end
    print("maximize: c'x =  ")
    for i in eachindex(c)
        print("$(c[i])$(x[i])")
        if i < length(c)
            print(" + ")
        end
    end
    println("")
    println("Subject to:")
    for i in eachindex(b)
        print("$(b[i]) = ")
        for j in eachindex(c)
            print("$(A[i, j])$(x[j])")
            if j < length(c)
                print(" + ")
            end
        end
        println("")
    end
    println("")
    for i in eachindex(x)
        print("$(x[i]) >= 0")
    end
 end
 
function algebraic_initial_dictionary(;c, b, A, x)
    print("ζ =  ")
    for i in eachindex(c)
        print("$(c[i])$(x[i])")
        if i < length(c)
            print(" + ")
        end
    end
    println("")
    println("Subject to:")
    for i in eachindex(b)
        for j in eachindex(c)
            print("$(A[i, j])$(x[j])")
            if j < length(c)
                print(" + ")
            end
        end
        print(" = $(b[i])")
        println("")
    end
    println("")
    for i in eachindex(x)
        print("$(x[i]) >= 0")
    end
end

mutable struct Dictionary
    A::Matrix{Float64}
    b::Vector{Float64}
    c::Vector{Float64}
    basic_variables::Vector{Int}
    nonbasic_variables::Vector{Int}
    objective_value::Float64
end


A, m, n = matrix_create(n = 20, m = 20)
A, b, c, x, basic_variables, nonbasic_variables = initialize(c = zeros(20), b = zeros(20), A = A, m = m, n = n)
//#println("Algebraic LP Formulation:")
algebraic_lp(c = c, b = b, A = A, x = x)
//#println("Initial Dictionary:")
D = Dictionary(A, b, c, basic_variables, nonbasic_variables, 0.0)
#Simplex.Solve_lp(D)

using JuMP, HiGHS

# Save the original dictionary before your solver changes it.
original = deepcopy(D)

model = Model(HiGHS.Optimizer)
set_silent(model)

n = length(original.c)
@variable(model, x[1:n] >= 0)
@constraint(model, original.A * x .<= original.b)

# Your pivot code uses ζ = ζ₀ - c'x.
@objective(model, Max,
    original.objective_value -
    sum(original.c[j] * x[j] for j in 1:n)
)

optimize!(model)

if is_solved_and_feasible(model)
    Simplex.Solve_lp(D)

    reference = objective_value(model)
    println("HiGHS objective: ", reference)
    println("Your objective:  ", D.objective_value)

    @assert isapprox(D.objective_value, reference;
                     atol = 1e-6, rtol = 1e-6) "Objective mismatch"
else
    println("HiGHS status: ", termination_status(model))
end