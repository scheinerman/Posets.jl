using Posets, LinearAlgebra

function lex_prod(p::Poset, q::Poset)
    A = zeta_matrix(p)
    B = zeta_matrix(q)
    AB = kron(A,B)

    return Poset(AB)

end