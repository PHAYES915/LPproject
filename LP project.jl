using Simplex
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
        b[i] = round(2rand() - 1, digits = 3)
    end
    # println("b: $b")
    
    for i in 1:m
        x[i] = "x$i"
    end
    # println("x: $x")
    basic_variables = collect(1:m)
    nonbasic_variables = collect(m+1:m+n)
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


A, m, n = matrix_create(n = 6, m = 5)
A, b, c, x, basic_variables, nonbasic_variables = initialize(c = [1.0,2.0,3.0,4.0,5.0], b = [4.0,5.0,6.0,7.0,8.0, 9.0], A = A, m = m, n = n)
//#println("Algebraic LP Formulation:")
algebraic_lp(c = c, b = b, A = A, x = x)
//#println("Initial Dictionary:")
D = Dictionary(A, b, c, basic_variables, nonbasic_variables, 0.0)
Solve_lp(D)

