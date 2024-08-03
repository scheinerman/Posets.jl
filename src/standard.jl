# Standard Posets

export chain, antichain, standard_example

"""
    chain(n::Integer)

Create an `n`-element poset in which `1 < 2 < ... < n`.
"""
function chain(n::Integer)
    p = Poset(n)
    for i = 1:n-1
        add_edge!(p.d, i, i + 1)
    end
    transitiveclosure!(p.d)
    return p
end


"""
    antichain(n::Integer)

Create an `n` element poset in which all pairs of elements are incomparable. 
"""
antichain(n::Integer) = Poset(n)


"""
    standard_example(n::Integer)

Poset with `2n` elements in two levels. Each element on the lower level is 
below `n-1` elements on the upper level. This is an example of a smallest-size 
poset of dimension `n`.
"""
function standard_example(n::Integer)
    p = Poset(2n)
    for a = 1:n
        for b = 1:n
            if a != b
                add_edge!(p.d, a, b + n)
            end
        end
    end
    return p
end
