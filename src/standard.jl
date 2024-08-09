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

This is equivalent to `crown(n,1)`.
"""
standard_example(n::Integer) = crown(n,1)

"""
    crown(n::Integer, k::Integer)::Poset{Int}

Create the crown poset `S(n,k)`. This is a height-`2` poset 
with `2n` vertices with elements `1` through `n` as minimals and 
`n+1` through `2n` as maximals. Minimal element `a` is below exactly
`n-k` maximals. Element `a` is *not* below elements `n+(a)` through `n+(a+k-1)`
where the terms in parentheses wrap modulo `n`. 

For example, in `crown(5,2)` element `2` is not below `7` or `8`, but 
`2<9`, `2<10`, and `2<6`.
"""
function crown(n::Integer, k::Integer)::Poset{Int}
    if !(0 ≤ k ≤ n)
        throw(DomainError("crown(n,k): must have 0 ≤ k ≤ n. Received n=$n and k=$k"))
    end

    p = Poset(2n)
    for a=1:n
        for j=k:n-1
            b = n + mod1(a+j,n)
            add_edge!(p.d, a, b)
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

"""
    subset_lattice(d::Integer)

Create the poset corresponding to the subsets of a `d`-element set 
ordered by inclusion. 
"""
function subset_lattice(d::Integer)::Poset
    codes = collect(UInt64(0):(UInt64(1) << d - 1))
    n = length(codes)
    g = DiGraph(n)

    for a in 1:n
        for b in 1:n
            if codes[a] & codes[b] == codes[a]
                add_edge!(g, a, b)
            end
        end
    end

    return Poset(g)
end

"""
    subset_decode(c::Integer)::Set{Int}

Convert a positive integer into a set of positive integers.
"""
function subset_decode(c::Integer)::Set{Int}
    bits = digits(c - 1; base=2)
    return Set{Int}(findall(bits .> 0))
end

"""
    subset_encode(A::Set{T})::Int where {T<:Integer}

Encode a set of positive integers into an integer.
"""
function subset_encode(A::Set{T})::Int where {T<:Integer}
    s = 0
    for k in A
        s += 1 << (k - 1)
    end
    return s + 1
end
