# methods for dealing with relations

import Graphs: src, dst

export nr, has_relation, add_relation!, Relation, relations, src, dst

"""
    nr(p::Poset)

Return the number of relations in the poset `p`.
"""
nr(p::Poset) = ne(p.d)

"""
    has_relation(p::Poset,a::Integer,b::Integer)

Determine if `a<b` is a relation in `p`.
"""
has_relation(p::Poset, a::Integer, b::Integer) = has_edge(p.d, a, b)

"""
    add_relation!(p::Poset, a::Integer, b::Integer)::Bool

Add `a<b` as a relation in the poset. Returns `true` if successful.
"""
function add_relation!(p::Poset, a::Integer, b::Integer)::Bool
    n = nv(p)

    # check that element names are in range and distinct
    if a < 1 || a > n || b < 1 || b > n || a == b
        return false
    end

    # check if we already have a and b related (either way)
    if has_relation(p, a, b) || has_relation(p, b, a)
        return false
    end

    # in this case, we can add the relation a<b & execute transitive closure
    add_edge!(p.d, a, b)
    transitiveclosure!(p.d)
    return true
end

struct Relation{T<:Integer}
    e::Edge{T}
    function Relation(e::Edge{T}) where {T}
        new{T}(e)
    end
end


src(r::Relation) = src(r.e)
dst(r::Relation) = dst(r.e)

function show(io::IO, ab::Relation)
    print(io, "Relation $(src(ab)) < $(dst(ab))")
end

"""
    relations(p::Poset)

Return an iterator for the relations in `p`.
"""
function relations(p::Poset)
    (Relation(e) for e in edges(p.d))
end