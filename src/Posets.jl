module Posets

using Graphs

import Base: eltype, show


import Graphs: add_vertex!, add_vertices!, add_edge!, nv


export Poset, add_vertex!, add_vertices!, nv

abstract type AbstractPoset{T<:Integer} end

struct Poset{T<:Integer} <: AbstractPoset{T}
    d::SimpleDiGraph{T}

    function Poset{T}(n::Int) where {T}
        new{T}(SimpleDiGraph{T}(n))
    end
end
Poset(n::Int = 0) = Poset{Int}(n)

include("graph_clones.jl")
include("relations.jl")

end # module Posets
