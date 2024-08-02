## methods extended from Graphs to Posets
"""
    nv(p::Poset)

Number of elements in the poset `p`.
"""
nv(p::Poset) = nv(p.d)

"""
    eltype(p)

Return the type of the poset's vertices (must be <: Integer)
"""
eltype(::Poset{T}) where {T} = T

"""
    add_vertex!(p::Poset)

Add a new vertex to the poset `p`. Return `true` if addition was successful.
"""
add_vertex!(p::Poset) = add_vertex!(p.d)


"""
    add_vertices!(p::Poset, n::Integer)

Add `n` new vertices to the poset `p`. Return the number of vertices that were added successfully.
"""
add_vertices!(p::Poset, n::Integer) = add_vertices!(p.d, n)


"""
    rem_vertex!(p::Poset, v::Integer)

Remove element `v` from `p`. The last element in `p` takes its place.  Returns `true`
if successful.
"""
rem_vertex!(p::Poset, v::Integer) = rem_vertex!(p.d, v)


# Print in a format similar to SimpleDiGraph
show(io::IO, p::Poset{T}) where {T} = write(io, "{$(nv(p))} $T poset")
