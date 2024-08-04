"""
    connected_components(p::Poset)

Return the connected components of the poset `p`.
"""
connected_components(p::Poset) = connected_components(p.d)


"""
    is_connected(p::Poset)

Determine if the poset `p` is connected.
"""
is_connected(p::Poset) = is_connected(p.d)