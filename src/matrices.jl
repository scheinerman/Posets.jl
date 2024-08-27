# zeta and Möbius matrices

"""
    zeta_matrix(p::Poset)

Return the zeta matrix of `p`. This is a (dense) 0,1-matrix whose `i,j`-entry 
is `1` exactly when `p[i] ≤ p[j]`. See also `strict_zeta_matrix`.
"""
zeta_matrix(p::Poset) = strict_zeta_matrix(p) + I

"""
    strict_zeta_matrix(p::Poset)

Return the  *strict* zeta matrix of `p`. This is a (dense) 0,1-matrix whose `i,j`-entry 
is `1` exactly when `p[i] < p[j]`. See also `zeta_matrix`.
"""
strict_zeta_matrix(p::Poset) = Matrix(adjacency_matrix(p.d))

"""
    mobius_matrix(p::Poset):: Matrix{Int}

Return the inverse `zeta_matrix(p)`.
"""
function mobius_matrix(p::Poset)
    Z = zeta_matrix(p)
    return Int.(round.(inv(Z)))
end
