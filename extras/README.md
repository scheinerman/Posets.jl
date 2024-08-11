# Extras for `Posets`

This folder contains extra code that may be interesting/useful
in working with partially ordered sets. 

Some of these files are sequestered here
because they load other packages. Some might be of marginal value. Some
might be incorporated into `Posets` in the future. 


## `containment_order.jl`

Function provided:

*  `containment_order(list)`:
  Given a list of distinct objects for which `issubseteq` is defined, 
  create a poset `p` in which `i<j` exactly when `list[i] ⊆ list[j]`.

## `converter.jl`

This file provides the function `poset_converter` that may be use to convert a poset
defined in this `Posets` module (called `Poset`) to a poset (called `SimplePoset`)
in the [SimplePosets](https://github.com/scheinerman/SimplePosets.jl) module.
A simple call to `poset_convert(p)` converts `p` from one
type to the other. 

> **Note**: The functions defined in the `Poset` and `SimplePoset` have a lot of the same names. This can cause conflicts. It may be necessary to invoke a function `f` either as `Posets.f` or `SimplePosets.f` to deal with the clash. 

## `divisors.jl`

Function provided:

* `divisors_poset(n)`: Create a poset whose elements correspond to the divisors of 
  the (positive) integer `n`. In this poset we have `a < b` provided the `a`-th divisor of `n`
  is a factor of the `b`-th divisor. 
* This can also be invoked as `divisor_poset(list)` where `list` is a list (`Vector`) of 
  distinct positive integers to be ordered by divisibility. 


## `interval-orders.jl`

Functions provided:

* `semiorder(xs)` creates a semiorder. Here `xs` is a list of `n` real numbers. 
The result is a poset with `n` elements in which `i<j` when `x[i] ≤ x[j]-1`. 
More generally, use `semiorder(xs,t)` in which case `i<j` when `x[i] ≤ x[j]-t`. 
Setting `t=0` gives a total order (if the values in `xs` are distinct). 
If `t` is negative, errors may be thrown. 

* `interval_order(JJ)` creates an interval order. Here `JJ` is a vector of
`ClosedInterval`s. In this poset we have `a < b` provided `JJ[a]` lies entirely
to the left of `JJ[b]`.

* `random_interval_order(n)` creates a random interval order with `n` elements. This is done by
creating `n` random intervals and invoking `interval_order`. 

## `partition-lattice.jl`

The function `partition_lattice(n)` returns a pair `(p, tab)`. 
* `p` is the poset containing all partitions of the set `{1,2,...,n}` ordered by refinement. 
  The least element of this poset is `{{1},{2},...,{n}}` and the largest element of this poset is `{{1,2,...,n}}`.
* `tab` is table containing the partitions of `{1,2,...,n}` so that element `a` of `p` 
  corresponds to the parition `tab[a]`.

The function `partition_lattice_demo` prints out a maximal chain in a partition lattice. 
```
julia> using ShowSet

julia> partition_lattice_demo(5)
{{1},{2},{4},{3},{5}} < {{1,5},{2},{4},{3}} < {{4},{3},{1,2,5}} < {{1,2,4,5},{3}} < {{1,2,3,4,5}}
```



## `pplot.jl`

Function provided:
* `pplot(p)`: draw a picture of (the cover digraph of) `p`. An edge `v → w` means 
`v < w` and `w` covers `v`. Use `pplot(p, nodelable=1:nv(p))` to have the nodes labeled.

Based on `gplot` from [GraphPlot](https://github.com/JuliaGraphs/GraphPlot.jl).

(I like the pictures produced by `posetplot.jl` better. I might just delete this. )

## `posetplot.jl`

Function provided:
* `posetplot(p)`: draw a picture of (the cover digraph of) `p`. An edge from `v` upward to `w`
  means `v < w` and `w` covers `v`. (No arrows are drawn; this is a Hasse diagram.)

Based on `graphplot` from [GraphMakie](https://graph.makie.org/stable/) and using [LayeredLayouts](https://github.com/oxinabox/LayeredLayouts.jl).


## `vertex-edge.jl`

Function provided:

* `vertex_edge_poset(g)`: Given a graph `g`, create `p`, the vertex-edge poset of `g`.
  The elements of `p` correspond to the vertices and edgs of
  `g`. We have `v < e` is `p` exactly when `v` is a vertex, 
  `e` is an edge, and `v` is an end point of `v`.