module Posets

using Graphs

import Base: eltype, show, ==


import Graphs: add_vertex!, add_vertices!, add_edge!, rem_vertex!, nv


export Poset, add_vertex!, add_vertices!, rem_vertex!, ==

abstract type AbstractPoset{T<:Integer} end

struct Poset{T<:Integer} <: AbstractPoset{T}
    d::SimpleDiGraph{T}

    function Poset{T}(n::Int) where {T}
        new{T}(SimpleDiGraph{T}(n))
    end
end
Poset(n::Int = 0) = Poset{Int}(n)

(==)(p::Poset, q::Poset) = p.d == q.d


# Print in a format similar to SimpleDiGraph
show(io::IO, p::Poset{T}) where {T} = print(io, "{$(nv(p))} $T poset")



include("graph_clones.jl")
include("relations.jl")
include("constructors.jl")

end # module Posets
