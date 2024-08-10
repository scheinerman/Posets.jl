using Posets
using SimplePosets

"""
    poset_convert(p::Poset)::SimplePoset{Int}

Convert a `Poset` (from the `Posets` module) to a `SimplePoset`
(from the `SimplePosets` module).
"""
function poset_convert(p::Poset)::SimplePoset{Int}
    n = Posets.nv(p)
    rels = Posets.relations(p)

    # create empty 
    P = SimplePosets.Antichain(n)
    for r in rels
        a = src(r)
        b = dst(r)
        add!(P.D, a, b)
    end
    return P
end



function poset_convert(P::SimplePoset{T}, V::Vector{T})::Poset{Int} where {T}
    n = card(P)
    p = Poset(n)

    rel_list = SimplePosets.relations(P)
    int_rel_list = [(V[a], V[b]) for (a, b) in rel_list]

    Posets.add_relations!(p, int_rel_list)
    return p
end

"""
    poset_convert(P::SimplePoset{T})::Poset{Int} where {T}
    poset_convert(P::SimplePoset{T}, V::Vector{T})::Poset{Int} where {T,S<:Integer}

Convert a `SimplePoset` (from the `SimplePosets` module) to a `Poset` (from the `Posets` module).
The list `V` should contain the vertices of `P`.

If `V` is omitted, the it is automatically set as `V = elements(P)`.
"""
function poset_convert(P::SimplePoset{T})::Poset{Int} where {T}
    n = card(P)
    V = elements(P)
    return poset_convert(P, V)
end
