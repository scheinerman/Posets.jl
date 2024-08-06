# Standard Posets

"""
    chain(n::Integer)

Create an `n`-element poset in which `1 < 2 < ... < n`.
"""
function chain(n::Integer)
    p = Poset(n)
    for i in 1:(n - 1)
        add_edge!(p.d, i, i + 1)
    end
    transitiveclosure!(p.d)
    return p
end

"""
    chain(vlist::Vector{T}) where {T<:Integer}

Create a chain with elements drawn from `vlist`, which must be a permutation of `1:n`.
For example, `chain([2,1,3])` returns a poset in which `2 < 1 < 3`.
"""
function chain(vlist::Vector{T}) where {T<:Integer}
    n = length(vlist)
    if sort(vlist) != collect(1:n)
        throw(ArgumentError("List of numbers must be a permutation of 1:n"))
    end

    p = Poset(n)
    for i in 1:(n - 1)
        add_edge!(p.d, vlist[i], vlist[i + 1])
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
    for a in 1:n
        for b in 1:n
            if a != b
                add_edge!(p.d, a, b + n)
            end
        end
    end
    return p
end

"""
    chevron()

Return the chevron poset, a poset with 6 elements that has dimension equal to 3. 
"""
function chevron()
    p = Poset(6)

    add_relation!(p, 1, 3)
    add_relation!(p, 2, 3)
    add_relation!(p, 1, 4)
    add_relation!(p, 2, 5)
    add_relation!(p, 4, 6)
    add_relation!(p, 5, 6)

    return p
end
