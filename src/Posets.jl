module Posets

using Graphs
using LinearAlgebra

import Base: eltype, show, ==
import Graphs: add_vertex!, add_vertices!, add_edge!, rem_vertex!, nv

export Poset, add_vertex!, add_vertices!, rem_vertex!, ==

abstract type AbstractPoset{T<:Integer} end

struct Poset{T<:Integer} <: AbstractPoset{T}
    d::SimpleDiGraph{T}
    # construct a poset with no relations
    function Poset(n::T) where {T<:Integer}
        new{T}(SimpleDiGraph{T}(n))
    end

    # construct a poset from a directed graph 
    function Poset(d::DiGraph{T}) where {T}
        dd = DiGraph(d)  # make a copy
        n = nv(dd)
        # remove self loops
        for v = 1:n
            if has_edge(dd, v, v)
                rem_edge!(dd, v, v)
            end
        end

        # make sure it's acyclic
        if is_cyclic(dd)
            throw(ArgumentError("Cannot construct a poset from a DiGraph with cycles"))
        end
        new{T}(transitiveclosure(dd))
    end

    # copy constructor
    function Poset(p::Poset{T}) where {T}
        new{T}(DiGraph(p.d))
    end
end

Poset() = Poset(0)

# construct from a matrix
function Poset(A::T) where {T<:AbstractMatrix}
    d = DiGraph(A)
    return Poset(d)

end


(==)(p::Poset, q::Poset) = p.d == q.d


# Print in a format similar to SimpleDiGraph
show(io::IO, p::Poset{T}) where {T} = print(io, "{$(nv(p)), $(nr(p))} $T poset")



include("function_reuse.jl")
include("relations.jl")
include("standard.jl")
include("up-down.jl")
include("matrices.jl")
include("graphs.jl")
include("operations.jl")

end # module Posets