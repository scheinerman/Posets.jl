"""
    max_antichain(p::Poset)

Return a maximum size antichain of `p` (as a list).
"""
function max_antichain(p::Poset)
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
width(p::Poset) = length(max_antichain(p))

"""
    max_chain(p::Poset)

Return a maximum size chain of `p` (as a list). The 
chain elements are returned in order (least is first).
"""
function max_chain(p::Poset)
    n = nv(p)
    V = collect(1:n)
    MOD = Model(get_solver())

    @variable(MOD, x[V], Bin)

    for u in 1:(n - 1)
        for v in (u + 1):n
            if p(u, v) || p(v, u)
                continue
            end
            @constraint(MOD, x[u] + x[v] <= 1)
        end
    end

    @objective(MOD, Max, sum(x[v] for v in V))
    optimize!(MOD)

    X = value.(x)
    ch = [v for v in V if X[v] > 0.1]
    return _chain_sort(p, ch)
end

"""
    height(p::Poset)

Return the size of a maximum chain of `p`.
"""
height(p::Poset) = length(max_chain(p))

"""
    chain_cover(p::Poset, k::Integer)

Find a collection of `k` chains in `p` such that every vertex of `p`
is a member of one of those chains. If `k` is omitted, the width of `p`
is used. 
"""
function chain_cover(p::Poset, k::Integer)
    n = nv(p)
    MOD = Model(get_solver())

    # x[v,i]==1 means that vertex v belongs to chain i
    @variable(MOD, x[1:n, 1:k], Bin)

    # each vertex belongs to exactly one chain
    for v in 1:n
        @constraint(MOD, sum(x[v, i] for i in 1:k) == 1)
    end

    #incomparable vertices must be in different chains 
    for v in 1:(n - 1)
        for w in (v + 1):n
            if p(v, w) || p(w, v)
                continue
            end
            for i in 1:k
                @constraint(MOD, x[v, i] + x[w, i] <= 1)
            end
        end
    end

    optimize!(MOD)
    status = Int(termination_status(MOD))
    # status == 1 means success
    if status != 1
        error("No chain cover of size $k is possible.")
    end

    X = value.(x)
    chains = [findall(X[:, i] .> 0.1) for i in 1:k]
    return [_chain_sort(p, c) for c in chains]
end

chain_cover(p::Poset) = chain_cover(p, width(p))

function antichain_cover(p::Poset, k::Integer)
    n = nv(p)
    MOD = Model(get_solver())

    # x[v,i]==1 means that vertex v belongs to antichain i
    @variable(MOD, x[1:n, 1:k], Bin)

    # each vertex belongs to exactly one antichain
    for v in 1:n
        @constraint(MOD, sum(x[v, i] for i in 1:k) == 1)
    end

    #comparable vertices must be in different chains 
    for v in 1:(n - 1)
        for w in (v + 1):n
            if p(v, w) || p(w, v)
                for i in 1:k
                    @constraint(MOD, x[v, i] + x[w, i] <= 1)
                end
            end
        end
    end

    optimize!(MOD)
    status = Int(termination_status(MOD))
    # status == 1 means success
    if status != 1
        error("No antichain cover of size $k is possible.")
    end

    X = value.(x)
    chains = [findall(X[:, i] .> 0.1) for i in 1:k]
    return [_chain_sort(p, c) for c in chains]
end

antichain_cover(p::Poset) = antichain_cover(p, height(p))
