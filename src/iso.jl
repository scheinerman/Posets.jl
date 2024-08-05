
# We include our own graph isomorphism tester until such time 
# that Graphs has its own

_graphs_not_iso() = error("The graphs are not isomorphic")
function graph_iso(g::AbstractGraph, h::AbstractGraph)::Dict{Int,Int}
    n = nv(g)
    if n != nv(h)
        _graphs_not_iso()
    end

    # other simple tests can go here, for example:
    if ne(g) != ne(h)
        _graphs_not_iso()
    end

    A = adjacency_matrix(g)
    B = adjacency_matrix(h)
    MOD = Model(get_solver())
    @variable(MOD, X[1:n, 1:n], Bin)

    # success when A*X = X*B and X is permutation 

    # X must be doubly stochastic ==> permutation
    for i in 1:n
        @constraint(MOD, sum(X[i, j] for j in 1:n) == 1)
        @constraint(MOD, sum(X[j, i] for j in 1:n) == 1)
    end

    # A*X = X*B 
    for i in 1:n
        for k in 1:n
            @constraint(
                MOD,
                sum(A[i, j] * X[j, k] for j in 1:n) == sum(X[i, j] * B[j, k] for j in 1:n)
            )
        end
    end

    optimize!(MOD)
    status = Int(termination_status(MOD))

    # status == 1 means success
    if status != 1
        _graphs_not_iso()
    end

    # get the matrix
    P = Int.(value.(X))

    # convert to a dictionary
    result = Dict{Int,Int}()
    for v in 1:n
        for w in 1:n
            if P[v, w] > 0
                result[v] = w
            end
        end
    end

    return result
end

_posets_not_iso() = error("The posets are not isomorphic")

"""
    iso(p::Poset, q::Poset)::Dict{Int,Int}

Find an isomorphism from poset `p` to poset `q`, or throw an error 
if the posets are not isomorphic. A dictionary is returned mapping
vertices of `p` to vertices of `q`.
"""
function iso(p::Poset, q::Poset)::Dict{Int,Int}
    try
        result = graph_iso(p.d, q.d)
        return result
    catch
        _posets_not_iso()
    end
end

"""
    iso_check(p::Poset, q::Poset)::Bool

Return `true` if the posets are isomorphic and `false` if not.
"""
function iso_check(p::Poset, q::Poset)::Bool
    try
        iso(p, q)
        return true
    catch
        return false
    end
end
