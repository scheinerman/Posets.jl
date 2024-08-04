# methods for dealing with relations

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

(p::Poset)(a::Integer, b::Integer) = has_relation(p, a, b)

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
        return new{T}(e)
    end
end


src(r::Relation) = src(r.e)
dst(r::Relation) = dst(r.e)

show(io::IO, ab::Relation) = print(io, "Relation $(src(ab)) < $(dst(ab))")

"""
    relations(p::Poset)

Return an iterator for the relations in `p`.
"""
function relations(p::Poset)
    return (Relation(e) for e in edges(p.d))
end




###
# The following code enables p[i] < p[j] syntax for has(p,i,j)
##
struct PosetElement
    p::Poset
    x::Integer
    function PosetElement(p::Poset, x::Integer)
        if x <= 0 || x > nv(p)
            throw(ArgumentError("$x is not in this poset"))
        end
        return new(p, x)
    end
end

show(io::IO, pe::PosetElement) = print(io, "Element $(pe.x) in a $(pe.p)")

getindex(p::Poset, x::Integer) = PosetElement(p, x)

function _cannot_compare()
    throw(ArgumentError("Cannot compare elements of different posets"))
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



# COVERING

"""
    covered_by(p::Poset, a::Integer, b::Integer)::Bool

Return `true` is `a < b` in `p` and there is no element `c` with `a < c < b`.
"""
function covered_by(p::Poset, a::Integer, b::Integer)::Bool
    return p(a, b) && length(collect(between(p, a, b))) == 0
end

"""
    (<<)(a::PosetElement, b::PosetElement)::Bool

`p[u] << p[v]` returns `true` exactly when `u` is covered by `v`.
"""
function (<<)(a::PosetElement, b::PosetElement)::Bool
    if a.p != b.p
        _cannot_compare()
    end
    return covered_by(a.p, a.x, b.x)
end

"""
    (>>)(a::PosetElement, b::PosetElement)::Bool

`p[u] >> p[v]` returns `true` exactly when `v` is covered by `u`.
"""
(>>)(a::PosetElement, b::PosetElement)::Bool = b << a


"""
    just_below(p::Poset, a::Integer)

Return an iterator for the elements of `p` that `a` covers.

See also: `below`.
"""
function just_below(p::Poset, a::Integer)
    return (k for k = 1:nv(p) if covered_by(p, k, a))
end


"""
    just_above(p::Poset, a::Integer)

Return an iterator for the elements of `p` that cover `a`.

See also: `above`.
"""
function just_above(p::Poset, a::Integer)
    return (k for k = 1:nv(p) if covered_by(p, a, k))
end


"""
    maximals(p::Poset)

Return an iterator for all maximal elements of `p`.
"""
function maximals(p::Poset)
    return (v for v = 1:nv(p) if outdegree(p.d, v) == 0)
end

"""
    minimals(p::Poset)

Return an iterator for all minimal elements of `p`.
"""
function minimals(p::Poset)
    return (v for v = 1:nv(p) if indegree(p.d, v) == 0)
end


"""
    issubset(p::Poset, q::Poset)

Return `true` is `nv(p) <= nv(q)` and if `v < w` in `p`, then also 
`v < w` in `q`.
"""
issubset(p::Poset, q::Poset) = p.d ⊆ q.d