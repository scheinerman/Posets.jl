# zeta and Möbius matrices

"""
    zeta_matrix(p::Poset)::Matrix{Int}

Return the zeta matrix of `p`. This is a (dense) 0,1-matrix whose `i,j`-entry 
is `1` exactly when `p[i] ≤ p[j]`.
"""
function zeta_matrix(p::Poset)::Matrix{Int}
    return Matrix(adjacency_matrix(p.d) + I)
end

"""
    mobius_matrix(p::Poset):: Matrix{Int}

Return the inverse `zeta_matrix(p)`.
"""
function mobius_matrix(p::Poset)::Matrix{Int}
    Z = zeta_matrix(p)
    return Int.(inv(Z))
end
