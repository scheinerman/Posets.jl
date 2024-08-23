
"""
    _zeros_to_missing(A::AbstractMatrix{T}) where {T}

Create a new matrix by chaning all zero entries in a matrix to `missing`.

This is to preprocess strict zeta matrices before handing off to `hungarian`.
"""
function _zeros_to_missing(A::AbstractMatrix{T}) where {T}
    TM = Union{T,Missing}
    B = Matrix{TM}(A)
    r, c = size(B)
    for i in 1:r
        for j in 1:c
            if B[i, j] == 0
                B[i, j] = missing
            end
        end
    end
    return B
end

"""
    max_antichain(p::Poset)

Return a maximum size antichain of `p` (as a list).
"""
function max_antichain(p::Poset)
    n = nv(p)
    V = collect(1:n)
    MOD = Model(get_solver())
    @variable(MOD, x[V], Bin)

    CC = chain_cover(p)
    nCC = length(CC)

    for ch in CC
        @constraint(MOD, sum(x[c] for c in ch) == 1)
    end

    for i in 1:(nCC - 1)
        for j in (i + 1):nCC
            gen = ((u, v) for u in CC[i] for v in CC[j] if p[u] ⟂ p[v])
            for uv in gen
                u, v = uv
                @constraint(MOD, x[u] + x[v] <= 1)
            end
        end
    end
    optimize!(MOD)
    X = value.(x)
    return [v for v in V if X[v] > 0.1]
end



function old_max_antichain(p::Poset)
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
function width(p::Poset)::Int
    if nr(p) == 0   # corner case needed to avoid glitch in hungarian
        return nv(p)
    end

    A = _zeros_to_missing(strict_zeta_matrix(p))
    _, a = hungarian(A)
    return nv(p) - a
end

"""
    max_chain(p::Poset)

Return a maximum size chain of `p` (as a list). The 
chain elements are returned in order (least is first).
"""
max_chain(p::Poset) = dag_longest_path(p.d)

"""
    height(p::Poset)

Return the size of a maximum chain of `p`.
"""
height(p::Poset) = length(max_chain(p))

"""
    chain_cover(p::Poset)

Find a minimal collection of chains in `p` such that every vertex of `p`
is a member of one of those chains. The number of chains is the width of `p`.
"""
function chain_cover(p::Poset)::Vector{Vector{Int}}
    n = nv(p)

    if n == 0
        return Vector{Vector{Int}}()
    end

    if nr(p) == 0
        return [[v] for v in 1:nv(p)]
    end

    A = _zeros_to_missing(strict_zeta_matrix(p))
    assg, _ = hungarian(A)

    rel_list = [(k, assg[k]) for k in 1:n if assg[k] != 0]
    q = Poset(n)
    add_relations!(q, rel_list)
    C = connected_components(q)

    return [_chain_sort(p, c) for c in C]
end

"""
    antichain_cover(p)

Find a collection of antichains in `p` such that every vertex of `p`
is a member of one of those antichains. The number of antichains is 
the height of `p`.
"""
function antichain_cover(p)
    n = nv(p)
    if n == 0
        return Vector{Vector{Int}}()
    end

    a1 = collect(minimals(p))  #bottoms form first antichain
    result = [a1]
    done = Set(a1)

    todo = setdiff(Set(1:n), done)   # not yet in an antichain
    while length(todo) > 0
        # next antichain are all elements whose downset are already done
        a = [v for v in todo if below(p, v) ⊆ done]
        sort!(a)
        append!(result, [a])
        done = done ∪ Set(a)
        todo = setdiff(Set(1:n), done)
    end

    return result
end

"""
    old_antichain_cover(p::Poset, k::Integer)

Find a collection of `k` antichains in `p` such that every vertex of `p`
is a member of one of those antichains. If `k` is omitted, the height of `p`
is used. 
"""
function old_antichain_cover(p::Poset, k::Integer)
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
