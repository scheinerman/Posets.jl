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


function poset_convert(P::SimplePoset{T}, d::Dict{T,S})::Poset{Int} where {T,S<:Integer}
    n = card(P)
    p = Poset(n)

    rel_list = SimplePosets.relations(P)
    int_rel_list = [(d[a], d[b]) for (a, b) in rel_list]

    Posets.add_relations!(p, int_rel_list)
    return p
end

"""
    poset_convert(P::SimplePoset{T})::Poset{Int} where {T}
    poset_convert(P::SimplePoset{T}, d::Dict{T,S})::Poset{Int} where {T,S<:Integer}

Convert a `SimplePoset` (from the `SimplePosets` module) to a `Poset` (from the `Posets` module).
The dictionary `d` maps the vertex names in `P` to integers `1` through `n` (where `n` is the 
number of elements in `P`). It's the user's responsibility to be sure that `d`'s keys are exactly 
the `n` elements of `P` and the `d`'s values are exactly the integers `1` through `n`. If not, 
bad things might happen. 

If `d` is omitted, then one will be created automatically.
"""
function poset_convert(P::SimplePoset{T})::Poset{Int} where {T}
    n = card(P)
    d = Dict{T,Int}()
    VP = elements(P)
    for j in 1:n
        d[VP[j]] = j
    end

    return poset_convert(P, d)
end
