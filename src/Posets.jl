"""
Partially ordered sets in Julia based on the `Graphs` module.
"""
module Posets

using Graphs
using LinearAlgebra
using Random

using ChooseOptimizer
using JuMP
using HiGHS

import Base:
    +,
    /,
    \,
    <,
    <<,
    ==,
    >>,
    adjoint,
    eltype,
    getindex,
    hcat,
    in,
    intersect,
    issubset,
    reverse,
    show,
    vcat

import Graphs:
    add_vertex!,
    add_vertices!,
    connected_components,
    dst,
    induced_subgraph,
    is_connected,
    nv,
    rem_vertex!,
    src

export Poset,
    Relation,
    above,
    add_relation!,
    add_vertex!,
    add_vertices!,
    antichain,
    are_comparable,
    are_incomparable,
    below,
    between,
    chain,
    chain_cover,
    chevron,
    crown,
    comparability_graph,
    connected_components,
    cover_digraph,
    covered_by,
    dimension,
    dst,
    dst,
    has_relation,
    height,
    in,
    induced_subposet,
    is_antichain,
    is_chain,
    is_connected,
    iso,
    iso_check,
    just_above,
    just_below,
    linear_extension,
    max_anti_chain,
    max_chain,
    maximals,
    minimals,
    mobius_matrix,
    nr,
    nv,
    random_linear_order,
    random_poset,
    realizer,
    relations,
    rem_relation!,
    rem_vertex!,
    semiorder,
    src,
    src,
    standard_example,
    subset_decode,
    subset_encode,
    subset_lattice,
    vertex_edge_incidence_poset,
    weak_order,
    width,
    zeta_matrix

function __init__()
    set_solver(HiGHS)
    set_solver_verbose(false)
    return nothing
end

abstract type AbstractPoset{T<:Integer} end

"""
A `Poset` is a (strict) partially ordered set on elements `{1,2,...,n}`.

Basic constructors:
* `Poset(n::Integer = 0)` create a poset with `n` elements (no relations).
* `Poset(d::DiGraph)` create a poset for a directed acyclic graph.
* `Poset(p::Poset)` copy constructor.
"""
struct Poset{T<:Integer} <: AbstractPoset{T}
    d::DiGraph{T}
    # construct a poset with no relations
    function Poset(n::T) where {T<:Integer}
        return new{T}(DiGraph{T}(n))
    end

    # construct a poset from a directed graph 
    function Poset(d::DiGraph{T}) where {T}
        dd = DiGraph(d)  # make a copy
        n = nv(dd)
        # remove self loops
        for v in 1:n
            if has_edge(dd, v, v)
                rem_edge!(dd, v, v)
            end
        end

        # make sure it's acyclic
        if is_cyclic(dd)
            throw(ArgumentError("Cannot construct a poset from a DiGraph with cycles"))
        end
        return new{T}(transitiveclosure(dd))
    end

    # copy constructor
    function Poset(p::Poset{T}) where {T}
        return new{T}(DiGraph(p.d))
    end
end

Poset() = Poset(0)

# construct from a matrix
function Poset(A::T) where {T<:AbstractMatrix}
    d = DiGraph(A)
    return Poset(d)
end

(==)(p::Poset, q::Poset) = p.d == q.d

# Print in a format similar to a DiGraph
show(io::IO, p::Poset{T}) where {T} = print(io, "{$(nv(p)), $(nr(p))} $T poset")

include("function_reuse.jl")
include("relations.jl")
include("standard.jl")
include("up-down.jl")
include("matrices.jl")
include("graphs.jl")
include("operations.jl")
include("connection.jl")

include("height-width.jl")
include("realizer.jl")
include("iso.jl")
include("random-posets.jl")

end # module Posets
