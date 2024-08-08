using Posets

"""
    containment_order(list::Vector{T}) where {T}

Given a list of distinct objects for which `issubseteq` is defined, 
create a poset `p` in which `i<j` exactly when 
`list[i] ⊆ list[j]`.
"""
function containment_order(list::Vector{T}) where {T}
    p = length(list)
    for i in 1:n
        a = list[i]
        for j in 1:n
            b = list[j]
            if (i != j) && (a ⊆ b)
                add_relation!(p, i, j)
            end
        end
    end
    return p
end
