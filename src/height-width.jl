
"""
    max_anti_chain(p::Poset)

Return a maximum size antichain of `p` (as a list).
"""
function max_anti_chain(p::Poset)
    n = nv(p)
    V = collect(1:n)
    R = collect(relations(p))
    MOD = Model(get_solver())

    @variable(MOD, x[V], Bin)

    for r in R
        u = src(r)
        v = dst(r)
        @constraint(MOD, x[u] + x[v] <= 1)
    end

    @objective(MOD, Max, sum(x[v] for v in V))
    optimize!(MOD)

    X = value.(x)
    return [v for v in V if X[v] > 0.1]
end

"""
    width(p::Poset)

Return the width of `p`, i.e., the size of a maximum antichain.
"""
width(p::Poset) = length(max_anti_chain(p))


"""
    max_chain(p::Poset)

Return a maximum size chain of `p` (as a list).
"""
function max_chain(p::Poset)
    n = nv(p)
    V = collect(1:n)
    MOD = Model(get_solver())

    @variable(MOD, x[V], Bin)

    for u = 1:n-1
        for v = u+1:n
            if p(u, v) || p(v, u)
                continue
            end
            @constraint(MOD, x[u] + x[v] <= 1)
        end
    end

    @objective(MOD, Max, sum(x[v] for v in V))
    optimize!(MOD)

    X = value.(x)
    return [v for v in V if X[v] > 0.1]
end


"""
    height(p::Poset)

Return the size of a maximum chain of `p`.
"""
height(p::Poset) = length(max_chain(p))