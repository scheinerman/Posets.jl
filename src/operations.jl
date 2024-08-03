# Methods to transform or combine posets  

import Base: +, /, reverse

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

    A = zeros(Int,np,nq)
    B = ones(Int, nq,np)

    ZZ = [Zp A; B Zq]
    return Poset(ZZ)
end
