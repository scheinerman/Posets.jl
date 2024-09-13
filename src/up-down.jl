"""
    above(p::Poset, a::Integer)

Return an iterator for all elements `k` such that `a < k`.
"""
function above(p::Poset, a::Integer)
    return (k for k in 1:nv(p) if p(a, k))
end

"""
    below(p::Poset, a::Integer)

Return an iterator for all elements `k` such that `k < a`.
"""
function below(p::Poset, a::Integer)
    return (k for k in 1:nv(p) if p(k, a))
end

"""
    between(p::Poset, a::Integer, b::Integer)

Return an iterator for all elements `k` such that `a < k < b`.
"""
function between(p::Poset, a::Integer, b::Integer)
    return (k for k in 1:nv(p) if p(a, k) && p(k, b))
end

"""
    ranking(p::Poset)::Dict{Int,Int}

Create a ranking of the poset `p`. This is a dictionary that 
gives a ranking for each element of `p`. Minimals have rank 0.
Elements that are over only minimals have grade 1. And so forth. 
"""
function ranking(p::Poset)::Dict{Int,Int}
    n = nv(p)
    gr = Dict{Int,Int}()
    for v in 1:n
        gr[v] = 0
    end
    done = Set{Int}()
    todo = Set{Int}(1:n)
    g = -1
    while length(todo) > 0
        g += 1
        next = [v for v in todo if below(p, v) ⊆ done]
        for x in next
            gr[x] = g
            delete!(todo, x)
            push!(done, x)
        end
    end
    return gr
end

"""
    dual_ranking(p::Poset, compact::Bool = true)::Dict{Int,Int}

A variant on `ranking` from `Posets` by combining `ranking` on both `p` 
and its dual. 

With `compact` set to `true` the levels are "collapsed" to be numbered 0,
1, 2, 3, etc. Otherwise, there may be gaps in the numbering and might not
start at 0.
"""
function dual_ranking(p::Poset, compact::Bool=true)::Dict{Int,Int}
    r1 = ranking(p)
    r2 = ranking(p')
    n = nv(p)

    for v in 1:n
        r1[v] -= r2[v]
    end

    if !compact
        return r1
    end

    vals = unique(sort(collect(values(r1))))
    nvals = length(vals)

    lookup = Dict{Int,Int}()

    for idx in 1:nvals
        v = vals[idx]
        lookup[v] = idx
    end

    rk = Dict{Int,Int}()
    for v in 1:n
        rk[v] = lookup[r1[v]] - 1
    end

    return rk
end
