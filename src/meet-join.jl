
"""
    vee(a::PosetElement, b::PosetElement)::PosetElement

Return the join of the two elements, or throw an error if no such join exists. 
Invoke like this: `p[x] ∨ p[y]`.
"""
function vee(a::PosetElement, b::PosetElement)::PosetElement
    p = a.p
    if p !== b.p   # different posets
        _cannot_compare()
    end

    # special case
    if a ≤ b
        return b
    end
    if a ≥ b
        return a
    end

    x = a.x
    y = b.x
    msg = "Elements $x and $y do not have a join in this poset"

    # these are the elements strictly above x and y
    overs = Set(above(p, x)) ∩ Set(above(p, y))

    if length(overs) == 0
        error(msg)
    end

    overlist = _chain_sort(p, collect(overs))

    z = first(overlist)  # candidate for the join 

    # check that z < every other element in overlist 
    no = length(overlist)

    for i in 2:no
        if !has_relation(p, z, overlist[i])
            error(msg)
        end
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
        _cannot_compare()
    end

    # special case
    if a ≤ b
        return a
    end
    if a ≥ b
        return b
    end

    x = a.x
    y = b.x
    msg = "Elements $x and $y do not have a join in this poset"

    # these are the elements strictly above x and y
    unders = Set(below(p, x)) ∩ Set(below(p, y))

    if length(unders) == 0
        error(msg)
    end

    underlist = _chain_sort(p, collect(unders))

    z = last(underlist)  # candidate for the join 

    # check that z > every other element in underlist 
    no = length(underlist)

    for i in 1:(no - 1)
        if !has_relation(p, underlist[i], z)
            error(msg)
        end
    end

    return p[z]
end
