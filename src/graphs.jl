# Graphs associated with Posets

export comparability_graph, cover_digraph, vertex_edge_incidence_poset


"""
    comparability_graph(p::Poset)

Return the comparability graph of `p`. This is graph in which there is an edge 
between `i` and `j` if and only if `p[i] < p[j]` or `p[j] < p[i]`.
"""
comparability_graph(p::Poset{T}) where {T} = Graph{T}(p.d)



"""
    cover_digraph(p::Poset{T}) where {T}

Create a directed graph with the same vertices a `p` in which there is 
an edge from `v` to `w` exactly when `v` is covered by `w` in `p`.
"""
function cover_digraph(p::Poset{T}) where {T}
    n = nv(p)
    g = DiGraph{T}(n)
    for v = 1:n
        for w in just_above(p, v)
            add_edge!(g, v, w)
        end
    end
    return g
end



"""
    vertex_edge_incidence_poset(g::AbstractGraph)

Given a graph `g` create a poset whose elements correspond to the vertices 
and edges of `g` in which the only relations are of the form `v < e` where `v` 
is a vertex that is an end point of edge `e`. 
"""
function vertex_edge_incidence_poset(g::AbstractGraph)
    n = nv(g)
    m = ne(g)
    p = Poset(n + m)

    elist = collect(edges(g))
    for j = 1:m
        e = elist[j]
        u = src(e)
        v = dst(e)
        add_relation!(p, u, j + n)
        add_relation!(p, v, j + n)
    end

    return p
end

