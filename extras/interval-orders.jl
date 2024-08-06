using ClosedIntervals
using Graphs
using Posets

"""
    semiorder(values::Vector{T}, thresh=1) where {T<:Real}

Create a semi-order from a list of numbers. In this poset we have `a<b` 
exactly when `values[a] ≤ values[b] - thresh`.
"""
function semiorder(values::Vector{T}, thresh=1)::Poset where {T<:Real}
    n = length(values)
    g = DiGraph(n)
    for a in 1:n
        for b in 1:n
            if values[a] <= values[b] - thresh
                add_edge!(g, a, b)
            end
        end
    end
    return Poset(g)
end

"""
    interval_order(JJ::Vector{ClosedInterval})

Create an interval order from a list of closed intervals. In this poset 
we have `a < b` provided `JJ[a]` lies entirely to the left of `JJ[b]`.
"""
function interval_order(JJ::Vector{ClosedInterval{T}})::Poset where {T}
    n = length(JJ)
    g = DiGraph(n)

    for a in 1:n
        for b in 1:n
            if JJ[a] << JJ[b]
                add_edge!(g, a, b)
            end
        end
    end

    return Poset(g)
end

"""
    random_interval_order(n::Integer)

Create a random interval order. To do this, we generate `n` 
random intervals joining pairs of iid uniform [0,1] random variables.
"""
function random_interval_order(n::Integer)
    JJ = [ClosedInterval(rand(), rand()) for _ in 1:n]
    return interval_order(JJ)
end

nothing
