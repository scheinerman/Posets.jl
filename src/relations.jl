# methods for dealing with relations

import Graphs: src, dst
import Base: getindex, <

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




###
# The following code enables p[i] < p[j] syntax for has(p,i,j)
##
struct PosetElement
    p::Poset
    x::Integer
    function PosetElement(p::Poset, x::Integer)
        if x < 0 || x > nv(p)
            throw(BoundsError(p, x))
        end
        new(p, x)
    end
end

show(io::IO, pe::PosetElement) = print(io, "Element $(pe.x) in $(pe.p)")

getindex(p::Poset, x::Integer) = PosetElement(p, x)

function _cannot_compare() 
    throw(error("Cannot compare elements of different posets"))
end

function (<)(a::PosetElement, b::PosetElement)::Bool
    if a.p !== b.p   # different posets
        _cannot_compare()
    end
    return has_relation(a.p, a.x, b.x)
end

function (==)(a::PosetElement, b::PosetElement)::Bool
    if a.p !== b.p
        _cannot_compare()
    end
    return a.x == b.x
end
