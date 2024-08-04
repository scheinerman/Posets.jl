# Extras for `Posets`

This folder contains extra code that may be interesting/useful
in working with partially ordered sets.

## `divisors.jl`

Functions provided:

* `divisors_poset(n)`: Create a poset whose elements correspond to the divisors of 
the (positive) integer `n`. In this poset we have `a < b` provided the `a`-th divisor of `n`
is a factor of the `b`-divisor. 


* `subsets_poset(n)`: Create a poset (isomorphic to) the $2^d$ subsets of a `d`-element set
ordered by inclusion. 

## `random_posets.jl`

Functions provided:
* `random_linear_order(n)`: Create a linear order in which the numbers `1` through `n` appear in 
random order.

* `random_poset(n,d=2)`: Create a random `d`-dimensional poset by intersecting `d` random linear orders,
each with `n` elements. 

## `pplot.jl`

Function provided:
* `pplot(p)`: draw a picture of (the cover digraph of) `p`. An edge `v → w` means 
`v < w` and `w` covers `v`. Use `pplot(p, nodelable=1:nv(p))` to have the nodes labeled.