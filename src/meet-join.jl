"""
    _lattice_op(p::Poset, x::Integer, y::Integer, join_flag::Bool)::Integer

Determine the join or meet of `x` and `y` in `p`. Return `0` if not possible. 
Return the join if `join_flag` is `true`. Otherwise, return the meet. 

Common code for `lattice_join` and `lattice_meet`.
"""
function _lattice_op(p::Poset, x::Integer, y::Integer, join_flag::Bool)::Integer
    n = nv(p)
    if x < 1 || x > n || y < 1 || y > n   # not in the poset
        return 0
    end
    if x == y
        return x
    end

    if has_relation(p, x, y)
        return join_flag ? y : x
    end

    # relatives are the set of elements above [below] both x and y
    # provided join_flag is true [false].
    relatives = Set{Int}()
    if join_flag
        relatives = Set{Int}(above(p, x)) ∩ Set{Int}(above(p, y))
    else
        relatives = Set{Int}(below(p, x) ∩ Set{Int}(below(p, y)))
    end

    if length(relatives) == 0
        return 0
    end

    relatives = _chain_sort(p, collect(relatives))  # make a sorted list

    # the join [meet] is the first element in relatives (if it exists)
    z = 0
    if join_flag
        z = first(relatives)
    else
        z = last(relatives)
    end

    # check if z is below [above] all the other elements in relatives
    nrels = length(relatives)
    if join_flag
        for i in 2:nrels
            if !has_relation(p, z, relatives[i])
                return 0
            end
        end
    else
        for i in 1:(nrels - 1)
            if !has_relation(p, relatives[i], z)
                return 0
            end
        end
    end

    return z
end

"""
    lattice_join(p, x, y)

Compute the join of `x` and `y` in `p`, or return `0` if it doesn't exist.
"""
lattice_join(p, x, y) = _lattice_op(p, x, y, true)

"""
    lattice_meet(p, x, y)

Compute the join of `x` and `y` in `p`, or return `0` if it doesn't exist.

"""
lattice_meet(p, x, y) = _lattice_op(p, x, y, false)

function _cannot_lattice_pq()
    throw(ArgumentError("Cannot compute join/meet of elements in different posets"))
end

"""
    vee(a::PosetElement, b::PosetElement)::PosetElement

Return the join of the two elements, or throw an error if no such join exists. 
Invoke like this: `p[x] ∨ p[y]`.
"""
function vee(a::PosetElement, b::PosetElement)::PosetElement
    p = a.p
    if p !== b.p   # different posets
        _cannot_lattice_pq()
    end
    x = integer(a)
    y = integer(b)
    z = _lattice_op(p, x, y, true)
    if z == 0
        throw(ArgumentError("$x ∨ $y does not exist in this poset"))
    end
    return p[z]
end

"""
    wedge(a::PosetElement, b::PosetElement)::PosetElement

Return the meet of the two elements, or throw an error if no such join exists. 
Invoke like this: `p[x] ∧ p[y]`.
"""
function wedge(a::PosetElement, b::PosetElement)::PosetElement
    p = a.p
    if p !== b.p   # different posets
        _cannot_lattice_pq()
    end
    x = integer(a)
    y = integer(b)
    z = _lattice_op(p, x, y, false)
    if z == 0
        throw(ArgumentError("$x ∧ $y does not exist in this poset"))
    end
    return p[z]
end

function join_table(p)
    n = nv(p)
    T = zeros(Int, n, n)
    for a in 1:n
        for b in a:n
            T[a, b] = lattice_join(p, a, b)
            T[b, a] = T[a, b]
        end
    end
    return T
end

function meet_table(p)
    n = nv(p)
    T = zeros(Int, n, n)
    for a in 1:n
        for b in a:n
            T[a, b] = lattice_meet(p, a, b)
            T[b, a] = T[a, b]
        end
    end
    return T
end
