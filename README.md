# Posets
Partially ordered sets for Julia based on [Graphs](https://juliagraphs.org/Graphs.jl/).

## Introduction: Partially Ordered Sets

A *partially ordered set*, or *poset* for short, is a pair $(V,<)$ where V is a set and
$<$ is a binary relation on $V$ that is
* irreflexive (for all $v \in V$, it is never the case that $v < v$),
* antisymmetric (for all $v,w \in V$, we never have both $v < w$ and $w < v$), and
* transitive (for all $u,v,w \in V$, if $u < v$ and $v < w$ then $u < w$).

Posets are naturally represented as transitively closed, directed, acyclic graphs. This is how this module implements posets using the `DiGraph` type in `Graphs`.

The design philosophy for this module is modeled exactly on `Graphs`. In particular, the vertex set of a poset is necessarily of the form `{1,2,...,n}`.

## Basics


### Construct new posets 

Create a new poset with no elements using `Poset()` or a poset with a specified number 
of elements with `Poset(n)`. 

Given a poset `p`, use `Poset(p)` to create an independent copy of `p`.

Given a directed graph `d`, use `Poset(d)` to create a new poset from the transitive 
closure of `d`. An error is thrown if `d` has cycles. (Self loops in `d` are ignored.)

Given a square matrix `A`, create a poset in which `i < j` exactly when the `i,j`-entry 
of `A` is nonzero. Diagonal entries are ignored. If this matrix would create a cycle, an 
error is thrown. 


### Adding elements

For consistency with `Graph`, we call the elements of a `Poset` *vertices* and the functions `add_vertex!` and `add_vertices!` work exactly as in the `Graphs` module.
```
julia> using Posets

julia> p = Poset()
{0, 0} Int64 poset

julia> add_vertex!(p)
true

julia> add_vertices!(p,5)
5

julia> p
{6, 0} Int64 poset
```
Use `nv(p)` to return the number of elements (vertices) in `p`.

### Adding relations
To add a relation to a poset, use `add_relation!`. This returns `true` when successful.
```
julia> p = Poset(4)
{4, 0} Int64 poset

julia> add_relation!(p,1,2)
true

julia> add_relation!(p,2,3)
true

julia> add_relation!(p,3,1)
false
```
Let's look at this carefully to understand why the third call to `add_relation!` does not succeed:

* The first call to `add_relation!` causes the relation `1 < 2` to hold in `p`. 
* The second call to `add_relation!` causes the relation `2 < 3` to be added to `p`. Given that `1 < 2` and `2 < 3`, by transitivity we automatically have `1 < 3` in `p`.
* Therefore, we cannot add `3 < 1` as a relation to this poset as that would violate antisymmetry.

### Removing elements

The function `rem_vertex!` behaves exactly as in `Graphs`. It removes the given vertex from the poset. For example:
```
julia> p = Poset(5)
{5, 0} Int64 poset

julia> add_relation!(p,1,5)
true

julia> rem_vertex!(p,2)
true

julia> has_relation(p,1,2)
true
```
When element `2` is removed from `p`, element `5` takes its place. 

### Removing relations
> *Removal of relations not implemented yet.*


## Inspection

### Vertices

Use `nv(p)` to return the number of vertices in the poset `p`. As in `Graphs`, the 
elements of the poset are integers from `1` to `n`. 

Use `in(a, p)` [or `a ∈ p`] to determine if `a` is an element of `p`. 
This is equivalent to `1 <= a <= nv(p)`.

### Relations

There are three ways to check if elements are related in a poset.

First, to see if  `1 < 3` in `p` we use the `has_relation` function:
```
julia> has_relation(p,1,3)
true
```

Second, the syntax `p(a,b)` is equivalent to `has_relation(p,a,b)`:
```
julia> p(1,3)
true

julia> p(3,1)
false
```

There is a third way to determine the relation between elements `a` and `b` in a poset `p`. Instead of `has_relation(p,a,b)` or `p(a,b)` we may use this instead: `p[a] < p[b]`.
```
julia> has_relation(p,1,3)
true

julia> p[1] < p[3]
true

julia> p[3] < p[1]
false
```
The other comparison operators (`<=`, `>`, `>=`, `==`, `!=`) works as expected.
```
julia> p[3] > p[1]
true
```


Neither `has_relation(p,a,b)` nor `p(a,b)` generate errors; they return `false` 
even if `a` or `b` are not elements of `p`. 
```
julia> p(-2,9)
false
```

However, the expression `p[a] < p[b]`  throws an error in either of these situations:
* Using the syntax `p[a]` if `a` is not an element of `p`.
* Trying to compare elements of different posets (even if the two posets are equal).

#### Comparability check

The functions `are_comparable(p,a,b)` and `are_incomparable(p,a,b)` behave as follows:
* `are_comparable(p,a,b)` returns `true` exactly when `a` and `b` are both in the poset, 
and one of the following is true: `a<b`, `a==b`, or `a>b`.
* `are_incompable(p,a,b)` returns `true` exactly when `a` and `b` are both in the poset, 
but none of the follower are true: `a<b`, `a==b`, or `a>b`.

#### Chain/antichain check

> TBW


### Counting/listing relations

Use `nr` to return the number of relations in the poset (this is analogous to `ne` in `Graphs`):
```
julia> nr(p)
3
```

The function `relations` returns an iterator for all the relations in a poset.
```
julia> p = chain(4)
{4, 6} Int64 poset

julia> collect(relations(p))
6-element Vector{Relation{Int64}}:
 Relation 1 < 2
 Relation 1 < 3
 Relation 1 < 4
 Relation 2 < 3
 Relation 2 < 4
 Relation 3 < 4
 ```
The functions `src` and `dst` return the lesser and greater elements of a relation, respectively:
```
julia> r = first(relations(p))
Relation 1 < 2

julia> src(r), dst(r)
(1, 2)
```

### Subset

* `issubset(p,q)` (or `p ⊆ q`) returns `true` exactly when `nv(p) ≤ nv(q)` and whenever `v < w` in 
`p` we also have `v < w` in `q`.

### Above, Below, Between

* `above(p,a)` returns an iterator for all elements `k` of `p` such that `a<k`.
* `below(p,a)` returns an iterator for all elements `k` of `p` such that `k<a`.
* `between(p,a,b)` returns an iterator for all elements `k` of `p` such that `a<k<b`.

```
julia> p = chain(10)
{10, 45} Int64 poset

julia> collect(above(p,6))
4-element Vector{Int64}:
  7
  8
  9
 10

julia> collect(below(p,6))
5-element Vector{Int64}:
 1
 2
 3
 4
 5

julia> collect(between(p,3,7))
3-element Vector{Int64}:
 4
 5
 6
 ```

### Covers

In a poset, we say `a` is covered by `b` provided `a < b` and there is no element `c` such 
that `a < c < b`.

Use `covered_by(p,a,b)` to determine if `a` is covered by `b`. Alternatively, use
`p[a] << p[b]` or `p[b] >> p[a]`.
```
julia> p = chain(8)
{8, 28} Int64 poset

julia> p[4] << p[5]
true

julia> p[4] << p[6]
false
```

The functions `just_above` and `just_below` can be used to find elements that cover, or are covered by, a given vertex.

```
julia> p = chain(9)
{9, 36} Int64 poset

julia> above(p,5) |> collect
4-element Vector{Int64}:
 6
 7
 8
 9

julia> just_above(p,5) |> collect
1-element Vector{Int64}:
 6

julia> below(p,5) |> collect
4-element Vector{Int64}:
 1
 2
 3
 4

julia> just_below(p,5) |> collect
1-element Vector{Int64}:
 4
 ```


### Maxmals/Minimals/Height/Width

* `maximals(p)` returns an iterator for the maximal elements of `p`.
* `minimals(p)` returns an iterator for the minimal elements of `p`.
* `max_chain(p)` returns a vector containing the elements of a largest chain in `p`.
* `max_antichain(p)` returns a vector containing the elements of a largest antichain in `p`.
* `height(p)` returns the size of a largest chain in `p`.
* `width(p)` returns the size of a largest antichain in `p`.
* `chain_cover(p, k)` returns a collection of `k` chains of `p` such that every element of 
`p` is in one of the chains. The parameter `k` is optional, in which case the width of `p` 
is used. (This is the smallest possible size of a chain cover per Dilworth's theorem.)

### Isomorphism

For posets `p` and `q`, use `iso(p,q)` to compute an isomorphism from `p` to `q`, 
or throw an error if the posets are not isomorphic.

Let `f = iso(p,q)`. Then `f` is a `Dict` mapping vertices of `p` to vertices of `q`. 
For example, if `p` has a unique minimal element `x`, then `f[x]` is the unique minimal
element of `q`. 

To check if posets are isomorphic, use `iso_check` (which calls `iso` inside a `try/catch` block).

### Realizers and dimension

A *realizer* for a poset `p` is a set of linear extensions whose intersection is `p`. 
The function `realizer(p, d)` returns a list of `d` linear extensions (total orders) 
that form a realizer of `p`, or throws an error if no realizer of that size exists.
```
julia> p = standard_example(3)
{6, 6} Int64 poset

julia> r = realizer(p, 3)
3-element Vector{Poset{Int64}}:
 {6, 15} Int64 poset
 {6, 15} Int64 poset
 {6, 15} Int64 poset

julia> r[1] ∩ r[2] ∩ r[3] == p
true

julia> realizer(p, 2)
ERROR: This poset has dimension greater than 2; no realizer found.
```

The *dimension* of a poset is the size of a smallest realizer. Use `dimension(p)` 
to calculate its dimension. 
```
julia> p = standard_example(4)
{8, 12} Int64 poset

julia> dimension(p)
4
```

> **Note**: Computation of the dimension of a poset is NP-hard. The `dimension` function may be
slow, even for moderate-size posets.


## Standard Posets

The following functions create standard partially ordered sets.

* `chain(n)` creates the poset with `n` elements in which `1 < 2 < 3 < ... < n`. 
* `chain(vlist)` creates a chain from the integer vector `vlist` (which must be a permutation of `1:n`). 
For example, `chain([2,1,3])` creates a chain in which `2 < 1 < 3`.
* `antichain(n)` creates the poset with `n` elements and no relations. Same as `Poset(n)`.
* `standard_example(n)` creates a poset with `2n` elements. Elements `1` through `n` form an antichain 
as do elements `n+1` through `2n`. The only relations are of the form `j < k` where `1 ≤ j ≤ n` 
and `k = n+i` where `1 ≤ i ≤ n` and `i ≠ j`. This is a smallest-size poset of dimension `n`.
* `chevron()` creates a poset with `6` elements that has dimension equal to `3`. It is 
different from `standard_example(3)`. 


## Graphs

Let `p` be a poset. The following two functions create graphs from `p` with the same 
vertex set as `p`:

* `comparability_graph(p)` creates an undirected graph in which there is an edge from `v` to `w` exactly when `v < w` or `w < v` in `p`.
* `cover_digraph(p)` creates a directed graph in which there is an edge from `v` to `w` exactly when `v` is covered by `w`.
```
julia> p = chain(9)
{9, 36} Int64 poset

julia> g = comparability_graph(p)
{9, 36} undirected simple Int64 graph

julia> g == complete_graph(9)
true

julia> d = cover_digraph(p)
{9, 8} directed simple Int64 graph

julia> d == path_digraph(9)
true
```

Given a graph `g`, calling `vertex_edge_incidence_poset(p)` creates a poset whose
elements correspond to the vertices and edges of `g`. In this poset the only relations
are of the form `v < e` where `v` is a vertex that is an end point of the edge `e`.


## Matrices

* `zeta_matrix(p)` returns the zeta matrix of the poset. This is a `0,1`-matrix whose
`i,j`-entry is `1` exactly when `p[i] ≤ p[j]`. 
* `mobius_matrix(p)` returns the inverse of `zeta(p)`. 

In both cases, the output is a dense, integer matrix. 


## Operations

### Dual
The dual of poset `p` is created using `reverse(p)`. This returns a new poset with the
same elements as `p` in which all relations are reversed (i.e., `v < w` in `p` if and 
only if `w < v` in `reverse(p)`). The dual (reverse) of `p` can also be created with `p'`. 

### Disjoint union
Given two posets `p` and `q`, the result of `p+q` is a new poset formed from the 
disjoint union of `p` and `q`. Note that `p+q` and `q+p` are isomorphic, but 
may be unequal because of the vertex numbering convention.

### Stack

Given two posets `p` and `q`, the result of `p/q` is a new poset from from a copy of `p` 
and a copy of `q` with all elements of `p` above all elements of `q`. 

### Induced subposet

Given a poset `p` and a list of vertices `vlist`, use `induced_subposet(p)` to return a 
pair `(q,vmap)`. The poset `q` is the induced subposet and the vector `vmap` maps
the new vertices to the old ones 
(the vertex `i` in the subposet corresponds to the vertex `vmap[i]` in `p`).

This is exactly analogous to `Graphs.induced_subgraph`. 

### Intersection

Given two posets `p` and `q`, `intersect(p,q)` is a new poset in which `v < w` if and only 
if `v < w` in both `p` and `q`. The number of elements is the smaller of `nv(p)` and `nv(q)`.
This may also be invoked as `p ∩ q`. 

For example, the intersection of a chain with its reversal has no relations:
```
julia> p = chain(5)
{5, 10} Int64 poset

julia> p ∩ reverse(p)
{5, 0} Int64 poset
```

### Linear extension

Use `linear_extension(p)` to create  a linear extension of `p`. 
This is a total order `q` with the same elements as `p` and with `p ⊆ q`. 


## See Also

The `extras` folder includes additional code that may be useful in 
working with `Posets`. See the `README` in that directory. 
