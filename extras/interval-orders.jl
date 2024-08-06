using Posets, Graphs, ClosedIntervals

"""
    semiorder(values::Vector{T}, thresh=1) where {T<:Real}

Create a semi-order from a list of numbers. In this poset we have `a<b` 
exactly when `values[a] ≤ values[b] - thresh`.
"""
function semiorder(values::Vector{T}, thresh=1) where {T<:Real}
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

nothing
