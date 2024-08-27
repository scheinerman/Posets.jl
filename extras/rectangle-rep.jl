using Posets, SimpleDrawing, Plots

"""
    rectangle_containment_representation(p::Poset, labels::Bool=true)

Give a poset `p` with `n` elements, draw `n` rectangles such that
the `i`-th rectangle is contained inside the `j`-th rectangle if and
only if `i < j` in `p`. 

This fails if `dimension(p)` is greater than `4`.

Use `rectangle_containment_representation(p, false)` to draw the representation 
without labels. 
"""
function rectangle_containment_representation(p::Poset, labels::Bool=true)
    newdraw()
    n = nv(p)
    R = realizer(p, 4)
    xyzw = [sortperm(Posets._chain2list(R[k])) for k in 1:4]

    for j in 1:n
        w = xyzw[1][j]
        x = xyzw[2][j]
        y = xyzw[3][j]
        z = xyzw[4][j]

        draw_rectangle(x, y, -z, -w; color=:black)
        labels && annotate!(-z, -w, "$j")
    end
    return finish()
end
