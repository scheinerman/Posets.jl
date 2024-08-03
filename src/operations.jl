# Methods to transform or combine posets  

import Base: +, /, reverse, intersect

"""
    reverse(p::Poset)

Create the dual of `p`, i.e., a poset with the same elements but with 
all relations reversed.
"""
function reverse(p::Poset)
    return Poset(reverse(p.d))
end



"""
    (+)(p::Poset, q::Poset)

`p+q`is the disjoint union of posets `p` and `q`
"""
function (+)(p::Poset, q::Poset)
    np = nv(p)
    nq = nv(q)

    Zp = zeta_matrix(p)
    Zq = zeta_matrix(q)

    A = zeros(Int, np, nq)

    ZZ = [Zp A; A' Zq]
    return Poset(ZZ)
end


"""
    (/)(p::Poset, q::Poset)

`p/q` creates a new poset by stacking `p` above `q`.
"""
function (/)(p::Poset, q::Poset)
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

The intersection of posets `p` and `q` (which must have the same number of elements)
is a new poset in which `v < w` if and only if `v < w` in poth `p` and `q`.
"""
function intersect(p::Poset, q::Poset)
    np = nv(p)
    nq = nv(q)
    if np != nq
        throw(AssertionError("Posets must have same number of elements: $np ≠ $nq"))
    end
    
    nn = promote(np,nq)[1]

    pq = Poset(nn)

    rel_p = relations(p)
    rel_q = relations(q)

    for r in rel_p 
        if r in rel_q 
            add_relation!(pq, src(r), dst(r))
        end
    end

    return pq
end
