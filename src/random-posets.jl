"""
    random_linear_order(n::Integer)

Create a random linear order on `n` elements.
"""
function random_linear_order(n::Integer)
    v = randperm(n)
    g = DiGraph(n)
    for i in 1:(n - 1)
        add_edge!(g, v[i], v[i + 1])
    end
    return Poset(g)
end

"""
    random_poset(n::Integer, d::Integer = 2)

Create a random `d`-dimensional order on `n` elements. 
"""
function random_poset(n::Integer, d::Integer=2)
    p = random_linear_order(n)
    for k in 2:d
        L = random_linear_order(n)
        p = p ∩ L
    end
    return p
end
