# Methods to transform or combine posets  

"""
    reverse(p::Poset)::Poset

Create the dual of `p`, i.e., a poset with the same elements but with 
all relations reversed.
"""
function reverse(p::Poset)::Poset
    return Poset(reverse(p.d))
end

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

