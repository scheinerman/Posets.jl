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
    if nv(p) == 0
        @warn "Cannot plot an empty poset"
        return nothing
    end
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

"""
    posetplot2d(p::Poset)

Draw a picture of a poset `p` whose dimension is at most 2. 
"""
function posetplot2d(p::Poset)
    if nv(p) == 0
        @warn "Cannot plot an empty poset"
        return nothing
    end

    g = transitivereduction(p.d)

    function _two_d_lay(::AbstractGraph)
        R = realizer(p, 2)
        x = sortperm(Posets._chain2list(R[1]))
        y = sortperm(Posets._chain2list(R[2]))

        rot = [1 -1; 1 1]
        XY = [x y] * rot'

        xx = XY[:, 1]
        yy = XY[:, 2]
        return Point.(xx, yy)
    end

    plt, ax, _ = graphplot(g; ilabels=1:nv(p), layout=_two_d_lay, arrow_show=false)
    hidedecorations!(ax)
    hidespines!(ax)
    return plt
end

nothing
