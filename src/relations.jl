# methods for dealing with relations
export nr, has_relation, add_relation!

"""
    nr(p::Poset)

Return the number of relations in the poset `p`.
"""
nr(p::Poset) = ne(p.d)

"""
    has_relation(p::Poset,a::Integer,b::Integer)

Determine if `a<b` is a relation in `p`.
"""
has_relation(p::Poset,a::Integer,b::Integer) = has_edge(p.d,a,b)

"""
    add_relation!(p::Poset, a::Integer, b::Integer)::Bool

Add `a<b` as a relation in the poset. Returns `true` if successful.
"""
function add_relation!(p::Poset, a::Integer, b::Integer)::Bool
    n = nv(p)

    # check that element names are in range and distinct
    if a<1 || a>n || b<1 || b>n || a==b
        return false
    end

    # check if we already have a and b related (either way)
    if has_relation(p,a,b) || has_relation(p,b,a)
        return false
    end

    # in this case, we can add the relation a<b & execute transitive closure
    add_edge!(p.d,a,b)
    transitiveclosure!(p.d)
    return true
end 