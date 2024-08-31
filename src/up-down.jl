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
