# Methods to transform or combine posets  

"""
    reverse(p::Poset)::Poset

Create the dual of `p`, i.e., a poset with the same elements but with 
all relations reversed. May also be invoked as `p'`.
"""
function reverse(p::Poset)::Poset
    return Poset(reverse(p.d))
end

adjoint(p::Poset) = reverse(p)

"""
    (+)(p::Poset, q::Poset)::Poset

`p+q`is the disjoint union of posets `p` and `q`.
"""
function (+)(p::Poset, q::Poset)::Poset
    np = nv(p)
    nq = nv(q)

    Zp = zeta_matrix(p)
    Zq = zeta_matrix(q)

    A = zeros(Int, np, nq)

    ZZ = [Zp A; A' Zq]
    return Poset(ZZ)
end

"""
    (/)(p::Poset, q::Poset)::Poset

`p/q` creates a new poset by stacking `p` above `q`.
"""
function (/)(p::Poset, q::Poset)::Poset
    np = nv(p)
    nq = nv(q)

    Zp = zeta_matrix(p)
    Zq = zeta_matrix(q)

    A = zeros(Int, np, nq)
    B = ones(Int, nq, np)

    ZZ = [Zp A; B Zq]
    return Poset(ZZ)
end

"""
    intersect(p::Poset, q::Poset)

The intersection of posets `p` and `q`. This is a new poset 
in which `v < w` if and only if `v < w` in both `p` and `q`.
The number of elements is the smaller of `nv(p)` and `nv(q)`.

May also be invoked as `p ∩ q`.
"""
intersect(p::Poset, q::Poset) = Poset(p.d ∩ q.d)

"""
    linear_extension(p::Poset)::Poset

Return a linear extension of `p`. This is a total order `q` with 
the same elements as `p` with `p ⊆ q`.
"""
function linear_extension(p::Poset)::Poset
    n = nv(p)
    seq = topological_sort(p.d)
    d = DiGraph(n)
    for i in 1:(n - 1)
        add_edge!(d, seq[i], seq[i + 1])
    end
    return Poset(d)
end

import Graphs: induced_subgraph
export induced_subposet

function induced_subposet(p::Poset, vlist::AbstractVector{T}) where {T<:Integer}
    g, m = induced_subgraph(p.d, vlist)
    q = Poset(g)
    return q, m
end
