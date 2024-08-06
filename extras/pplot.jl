using Posets
using Graphs
using GraphPlot

"""
    pplot(p::Poset; args...)

Draw a picture of `p` (only showing the cover digraph). 

Use `pplot(p, nodelabel=1:nv(p))` to have labeled vertices. 
"""
function pplot(p::Poset; args...)
    g = cover_digraph(p)
    return gplot(g; args...)
end

nothing
