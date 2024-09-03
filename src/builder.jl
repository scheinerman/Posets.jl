
"""
    poset_builder(objects::Vector{T}, comp_func::Function)::Poset where {T}

Given a list of `objects` and a function `comp_func` for comparing functions, 
create a `Poset` in which object `i` is less than object `j` provided 
`comp_func(objects[i], objects[j])` returns `true`. 
"""
function poset_builder(objects::Vector{T}, comp_func::Function)::Poset where {T}
    no = length(objects)
    if no == 0
        return Poset(0)
    end

    g = DiGraph(no)

    for u in 1:(no - 1)
        for v in (u + 1):no
            a = objects[u]
            b = objects[v]
            if comp_func(a, b)
                add_edge!(g, u, v)
            end
            if comp_func(b, a)
                add_edge!(g, v, u)
            end
        end
    end

    return Poset(g)
end
