using GLMakie
using GraphMakie
using LayeredLayouts
using Posets
using Graphs

"""
    posetplot(p::Poset)

Draw a picture of (the cover digraph of) the poset `p`.
"""
function posetplot(p::Poset)
    g = cover_digraph(p)
    plt, ax, _ = graphplot(g; ilabels=1:nv(p), layout=_zlay, arrow_show=false)
    hidedecorations!(ax)
    hidespines!(ax)
    return plt
end

function _zlay(g::AbstractGraph)
    xs, ys, _ = solve_positions(Zarate(), g)
    return Point.(zip(ys, xs))
end

nothing