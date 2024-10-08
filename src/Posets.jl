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
using Hungarian

import Base:
    +,
    *,
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
    isless,
    issubset,
    maximum,
    minimum,
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

import AbstractLattices: vee, wedge, ∨, ∧

export Poset,
    Relation,
    above,
    add_relation!,
    add_vertex!,
    add_vertices!,
    antichain,
    antichain_cover,
    are_comparable,
    are_incomparable,
    below,
    between,
    chain,
    chain_cover,
    chain2list,
    chevron,
    crown,
    comparability_graph,
    connected_components,
    cover_digraph,
    covered_by,
    dimension,
    dst,
    dual_ranking,
    has_relation,
    height,
    in,
    incidence_poset,
    induced_subposet,
    integer,
    is_antichain,
    is_chain,
    is_connected,
    iso,
    iso_check,
    join_table,
    just_above,
    just_below,
    lattice_join,
    lattice_meet,
    linear_extension,
    max_antichain,
    max_chain,
    maximals,
    meet_table,
    minimals,
    mobius_matrix,
    nr,
    nv,
    poset_builder,
    random_linear_extension,
    random_linear_order,
    random_poset,
    ranking,
    realizer,
    relations,
    rem_relation!,
    rem_vertex!,
    semiorder,
    src,
    standard_example,
    strict_zeta_matrix,
    subset_decode,
    subset_encode,
    subset_lattice,
    vertex_edge_incidence_poset,
    weak_order,
    width,
    zeta_matrix,
    ⟂,
    ∥,
    ∨,
    ∧

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
include("meet-join.jl")
include("connection.jl")
include("builder.jl")

include("height-width.jl")
include("realizer.jl")
include("iso.jl")
include("random-posets.jl")

end # module Posets
