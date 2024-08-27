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
    in(p::Poset, a::Integer)

Return true if `a` is a vertex of poset `p`. 
"""
in(a::Integer, p::Poset) = 1 <= a <= nv(p)

"""
    are_comparable(p::Poset, a::Integer, b::Integer)

Return `true` if `a<b` or `a==b` or `b<a`;  returns `false` if either
`a` or `b` is not in `p`.
"""
function are_comparable(p::Poset, a::Integer, b::Integer)::Bool
    if (a ∉ p) || (b ∉ p)
        return false
    end

    return (a == b) || has_relation(p, a, b) || has_relation(p, b, a)
end

"""
    are_incomparable(p::Poset, a::Integer, b::Integer)::Bool

Returns `true` provided both `a` and `b` are in `p` and none of the
following are true: `a<b` or `a==b` or `b<a`.
"""
function are_incomparable(p::Poset, a::Integer, b::Integer)::Bool
    if (a ∉ p) || (b ∉ p)
        return false
    end
    return !(are_comparable(p, a, b))
end

"""
    add_relation!(p::Poset, a::Integer, b::Integer)::Bool

Add `a<b` as a relation in the poset. Returns `true` if successful.

This may also be invoked as follows:
* `add_relation!(p, (a, b))` 
* `add_relation!(p, a => b)`
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

add_relation!(P, ab::Pair{S,T}) where {S<:Integer,T<:Integer} = add_relation!(P, ab...)
add_relation!(P, ab::Tuple{S,T}) where {S<:Integer,T<:Integer} = add_relation!(P, ab...)

"""
    Posets.add_relations!(p::Poset, rlist)

**WARNING!! This is a dangerous operation that may corrupt `p`.** 

Add a list of relations to a poset. The entries in the list `rlist` are 
either tuples `(a,b)` or pairs `a => b` of integers. 

When both `a` and `b` are valid vertices (distinct integers between `1` and `nv(p)`) the 
edge `(a,b)` is added into `p`'s data structure without any error checking. 

After the relations in `rlist` have been added to the data structure, 
if a cycle has been created an error is thrown (and the poset `p` is invalid).

Do not use this function unless absolutely sure no harm will be caused. 
Alternatively, first make a copy of `p`, exectute this function inside a 
`try`/`catch` block, and, if there is an error, `p` can be recovered from the 
saved copy. 

Example
=======
```
julia> p = Poset(10)
{10, 0} Int64 poset

julia> rlist = ((i,i+1) for i=1:9)
Base.Generator{UnitRange{Int64}, var"#13#14"}(var"#13#14"(), 1:9)

julia> Posets.add_relations!(p, rlist)

julia> p == chain(10)
true
```
"""
function add_relations!(p::Poset, rlist)
    for r in rlist
        if r[1] == r[2]  # ignore loops
            continue
        end
        add_edge!(p.d, r...)
    end

    if is_cyclic(p.d)
        error("This poset has been become corrupted!")
    end
    transitiveclosure!(p.d)

    return nothing
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
Int(a::PosetElement) = a.x

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

function (⟂)(a::PosetElement, b::PosetElement)::Bool
    if a.p !== b.p
        _cannot_compare()
    end
    return are_comparable(a.p, a.x, b.x)
end

(∥)(a::PosetElement, b::PosetElement)::Bool = !(a ⟂ b)

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
    return (k for k in 1:nv(p) if covered_by(p, k, a))
end

"""
    just_above(p::Poset, a::Integer)

Return an iterator for the elements of `p` that cover `a`.

See also: `above`.
"""
function just_above(p::Poset, a::Integer)
    return (k for k in 1:nv(p) if covered_by(p, a, k))
end

"""
    maximals(p::Poset)

Return an iterator for all maximal elements of `p`.
"""
function maximals(p::Poset)
    return (v for v in 1:nv(p) if outdegree(p.d, v) == 0)
end

"""
    minimals(p::Poset)

Return an iterator for all minimal elements of `p`.
"""
function minimals(p::Poset)
    return (v for v in 1:nv(p) if indegree(p.d, v) == 0)
end

"""
    issubset(p::Poset, q::Poset)

Return `true` is `nv(p) <= nv(q)` and if `v < w` in `p`, then also 
`v < w` in `q`.
"""
issubset(p::Poset, q::Poset) = p.d ⊆ q.d

"""
    is_chain(p::Poset, vlist)::Bool

Check if the elements in `vlist` form a chain in `p`.
"""
function is_chain(p::Poset, vlist)::Bool
    # make sure all elements of vlist are in p
    if !all(v ∈ p for v in vlist)
        return false
    end

    for v in vlist
        for w in vlist
            if !are_comparable(p, v, w)
                return false
            end
        end
    end
    return true
end

"""
    is_antichain(p::Poset, vlist)::Bool

Check if the elements in `vlist` form an antichain in `p`.
"""
function is_antichain(p::Poset, vlist)::Bool
    # make sure all elements of vlist are in p
    if !all(v ∈ p for v in vlist)
        return false
    end

    for v in vlist
        for w in vlist
            if v != w
                if are_comparable(p, v, w)
                    return false
                end
            end
        end
    end
    return true
end

"""
    rem_relation!(p::Poset, a::Integer, b::Integer)::Bool

Delete the relation `a < b` from the poset `p` as well as all 
relations of the form `a < x` and `x < b` where `x` is between
`a` and `b`.
"""
function rem_relation!(p::Poset, a::Integer, b::Integer)::Bool
    if !p(a, b)  # this is not a relation of the poset
        return false
    end

    mids = collect(between(p, a, b))  # vtcs between a and b 
    for c in mids
        rem_edge!(p.d, a, c)
        rem_edge!(p.d, c, b)
    end
    rem_edge!(p.d, a, b)
    return true
end

"""
    maximum(p::Poset)::Integer

Return the maximum element of `p` or `0` if there is no such element. 
"""
function maximum(p::Poset)::Integer
    n = nv(p)
    if n == 0
        return 0
    end
    vv = [v for v in 1:n if indegree(p.d, v) == n - 1]
    if length(vv) != 1
        return 0
    end
    return first(vv)
end

"""
    minimum(p::Poset)::Integer

Return the minimum element of `p` or `0` if there is no such element. 
"""
function minimum(p::Poset)::Integer
    n = nv(p)
    if n == 0
        return 0
    end
    vv = [v for v in 1:n if outdegree(p.d, v) == n - 1]
    if length(vv) != 1
        return 0
    end
    return first(vv)
end
