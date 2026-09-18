x = [1.0, 2.0]
f(x) = x[1]^2 + 3x[1]*x[2] + 2x[2]^2 + sin(x[1])

function partial_derivative(f, x::Vector, i; h=1e-5)
    plus = copy(x)
    minus = copy(x)
    plus[i] = x[i] + h
    #println(plus)
    minus[i] = x[i] - h
    #println(minus)
    numerator = f(plus)-f(minus) 
    denominator = 2 * h 
    approx_partial_x = numerator / denominator
    return approx_partial_x
end

function double_partial(f, x::Vector, i, j;h=1e-5, k=1e-5)
    if i != j 
        xpyp = copy(x)
        xpym = copy(x)
        xmyp = copy(x)
        xmym = copy(x)
        xpyp[i] = x[i] + h
        xpyp[j] = x[j] + k
        xpym[i] = x[i] + h
        xpym[j] = x[j] - k
        xmyp[i] = x[i] - h
        xmyp[j] = x[j] + k
        xmym[i] = x[i] - h
        xmym[j] = x[j] - k
        denominator = 4 * h * k
        numerator = f(xpyp) - f(xpym) - f(xmyp) + f(xmym)
        partial_i_partial_j = numerator / denominator
        return partial_i_partial_j
    else
        plus = copy(x)
        minus = copy(x)
        plus[i] = x[i] + h
        minus[i] = x[i] - h
        numerator = f(plus) - 2*f(x) + f(minus)
        denominator = h^2
        repeated_partial = numerator / denominator
    end
end
 
function repeated_partial(f, x, i, j)
end
function gradient(f,x)
    grad = zeros(length(x))
    for i in eachindex(x)
        grad[i] = partial_derivative(f, x, i)
    end
    return grad
end

function Hessian(f, x)
    Hes = zeros(eachindex(x),eachindex(x))
    for i in eachindex(x)
        for j in eachindex(x)
            Hes[i,j]= double_partial(f, x, i, j)
        end
    end
    return Hes
end

println(double_partial(f, x, 2, 2))
println(Hessian(f, x))
