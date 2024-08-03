# Posets
Partially ordered sets for Julia based on [Graphs](https://juliagraphs.org/Graphs.jl/).

## Partially ordered sets

A *partially ordered set*, or *poset* for short, is a pair $(V,<)$ where V is a set and
$<$ is a binary relation on $V$ that is
* irreflexive (for all $v \in V$, it is never the case that $v < v$),
* antisymmetric (for all $v,w \in V$, we never have both $v < w$ and $w < v$), and
* transitive (for all $u,v,w \in V$, if $u < v$ and $v < w$ then $u < w$).

Posets are naturally represented as transitively closed, directed, acyclic graphs. This is how this module implements posets using the `SimpleDiGraph` type in `Graphs`.

The design philosophy for this module is modeled exactly on `Graphs`. In particular, the vertex set of a poset is necessarily of the form $\{ 1,2,\ldots, n \}$.

## Basic functions


### Creating a poset and adding elements
Create a new poset with no elements using `Poset()` or a poset with a specified number of elements with `Poset(n)`. 

For consistency with `Graph`, we call the elements of a `Poset` *vertices* and the functions `add_vertex!` and `add_vertices!` work exactly as in the `Graphs` module.
```
julia> using Posets

julia> p = Poset()
{0} Int64 poset

julia> add_vertex!(p)
true

julia> add_vertices!(p,5)
5

julia> p
{6} Int64 poset
```
Use `nv(p)` to return the number of elements (vertices) in `p`.

### Adding relations
To add a relation to a poset, use `add_relation!`. This returns `true` when successful.
```
julia> p = Poset(4)
{4} Int64 poset

julia> add_relation!(p,1,2)
true

julia> add_relation!(p,2,3)
true

julia> add_relation!(p,3,1)
false
```
Let's look at this carefully to understand why the third call to `add_relation!` does not succeed:

* The first call to `add_relation!` causes the relation $1 < 2$ to hold in `p`. 
* The second call to `add_relation!` causes the relation $2 < 3$ to be added to `p`. Given that $1 < 2$ and $2 < 3$, by transitivity we automatically have $1 < 3$ in `p`.
* Therefore, we cannot add $3 < 1$ as a relation to this poset as that would violate antisymmetry.

We can check that $1 < 3$ in `p` using the `has_relation` function:
```
julia> has_relation(p,1,3)
true
```

> Not yet implemented: I hope to have `p[a] < p[b]` be equivalent to `has_relation!(p,a,b)` and likewise `p[a] > p[b]` or `p[a] <= p[b]`, etc.


Use `nr` to return the number of relations in the poset (this is analogous to `ne` in `Graphs`):
```
julia> nr(p)
3
```

> Not implemented yet: `relations(p)` creates an iterator for the relations in `p`.

### Removing elements and relations

The function `rem_vertex!` behaves exactly as in `Graphs`. It removes the given vertex from the poset. For example:
```
julia> p = Poset(5)
{5} Int64 poset

julia> add_relation!(p,1,5)
true

julia> rem_vertex!(p,2)
true

julia> has_relation(p,1,2)
true
```
When element 2 is removed from `p`, element 5 takes its place. 

> Removal of relations not implemented yet.

### Relation iterator

The function `relations` returns an iterator for all the relations in a poset.
```
julia> p = chain(4)
{4} Int64 poset

julia> collect(relations(p))
6-element Vector{Relation{Int64}}:
 Relation 1 < 2
 Relation 1 < 3
 Relation 1 < 4
 Relation 2 < 3
 Relation 2 < 4
 Relation 3 < 4
 ```
The functions `src` and `dst` return the less and greater elements of a relation, respectively:
```
julia> r = first(relations(p))
Relation 1 < 2

julia> src(r), dst(r)
(1, 2)
```

## Constructors

The following functions create standard partially ordered sets.

* `chain(n)` creates the poset with `n` elements in which $1 < 2 < 3 < \cdots < n$.
* `antichain(n)` creates the poset with `n` elements and no relations. Same as `Poset(n)`.
* `standard_example(n)` creates a poset with `2n` elements. Elements `1` through `n` form an antichain as do elements `n+1` through `2n`. The only relations are of the form `j < k` where `1 ≤ j ≤ n` and `k = n+i` where `1 ≤ i ≤ n` and `i ≠ j`. This is a smallest-size poset of dimension `n`.

> More to come


## Operations

> None implemented. Would like to see `reverse`, `+` (disjoint union), etc.