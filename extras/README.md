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


## `pplot.jl`

Function provided:
* `pplot(p)`: draw a picture of (the cover digraph of) `p`. An edge `v → w` means 
`v < w` and `w` covers `v`. Use `pplot(p, nodelable=1:nv(p))` to have the nodes labeled.


## `interval-orders.jl`

* `semiorder(xs)` creates a semiorder. Here `xs` is a list of `n` real numbers. 
The result is a poset with `n` elements in which `i<j` when `x[i] ≤ x[j] - 1`. 
More generally, use `semiorder(xs,t)` in which case `i<j` when `x[i] ≤ x[j] - t`. 
Setting `t=0` gives a total order (if the values in `xs` are distinct). 
If `t` is negative, errors may be thrown. 

* `interval_order(JJ)` creates an interval order. Here `JJ` is a vector of
`ClosedInterval`s. In this poset we have `a < b` provided `JJ[a]` lies entirely
to the left of `JJ[b]`.

* `random_interval_order(n)` creates a random interval order with `n` elements. This is done by
creating `n` random intervals and invoking `interval_order`. 