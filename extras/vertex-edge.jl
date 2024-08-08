using Graphs
using Posets

"""
    vertex_edge_poset(g::AbstractGraph)

Given a graph `g`, create `p`, the vertex-edge poset of `g`.

The elements of `p` correspond to the vertices and edgs of
`g`. We have `v < e` is `p` exactly when `v` is a vertex, 
`e` is an edge, and `v` is an end point of `v`.
"""
function vertex_edge_poset(g::AbstractGraph)
    n = nv(g)
    m = ne(g)

    p = Poset(n + m)

    V = collect(1:n)
    E = collect(edges(g))

    for v in 1:n
        for j in 1:m
            e = E[j]
            if src(e) == v || dst(e) == v
                add_relation!(p, v, j + n)
            end
        end
    end

    return p
end
