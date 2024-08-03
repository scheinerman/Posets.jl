# Posets
Partially ordered sets for Julia based on [Graphs](https://juliagraphs.org/Graphs.jl/).

## Introduction: Partially Ordered Sets

A *partially ordered set*, or *poset* for short, is a pair $(V,<)$ where V is a set and
$<$ is a binary relation on $V$ that is
* irreflexive (for all $v \in V$, it is never the case that $v < v$),
* antisymmetric (for all $v,w \in V$, we never have both $v < w$ and $w < v$), and
* transitive (for all $u,v,w \in V$, if $u < v$ and $v < w$ then $u < w$).

Posets are naturally represented as transitively closed, directed, acyclic graphs. This is how this module implements posets using the `SimpleDiGraph` type in `Graphs`.

The design philosophy for this module is modeled exactly on `Graphs`. In particular, the vertex set of a poset is necessarily of the form $\{ 1,2,\ldots, n \}$.

## Basics


### Construct new posets 

Create a new poset with no elements using `Poset()` or a poset with a specified number of elements with `Poset(n)`. 

Given a poset `p`, use `Poset(p)` to create an independent copy of `p`.

Given a directed graph `d`, use `Poset(d)` to create a new poset from the transitive 
closure of `d`. An error is thrown if `d` has cycles. (Self loops in `d` are ignored.)

Given a square matrix `A`, create a poset in which `i < j` exactly when the `i,j`-entry 
of `A` is nonzero. Diagonal entries are ignored, but if this would create a cycle an 
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

* The first call to `add_relation!` causes the relation $1 < 2$ to hold in `p`. 
* The second call to `add_relation!` causes the relation $2 < 3$ to be added to `p`. Given that $1 < 2$ and $2 < 3$, by transitivity we automatically have $1 < 3$ in `p`.
* Therefore, we cannot add $3 < 1$ as a relation to this poset as that would violate antisymmetry.

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
When element 2 is removed from `p`, element 5 takes its place. 

### Removing relations
> Removal of relations not implemented yet.


## Inspection

### Vertices

Use `nv(p)` to return the number of vertices in the poset `p`. As in `Graphs`, the 
elements of the poset are integers from `1` to `n`. 

### Checking relations

There are three ways to check if elements are related in a poset.

First, to see if  $1 < 3$ in `p` we use the `has_relation` function:
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

However, the expression `p[a] < p[b]`  throws an error in either or these situations:
* Using the syntax `p[a]` if `a` is not an element of `p`.
* Trying to compare elements of different posets (even if they are equal).

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

### Above, Below, Between

* `above(p,a)` returns an iterator for all elements `k` of `p` such that `a<k`.
* `below(p,a)` returns an iterator for all elements `k` of `p` such that `k<a`.
* `between(p,a,b)` eturns an iterator for all elements `k` of `p` such that `a<k<b`.

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


## Standard Posets

The following functions create standard partially ordered sets.

* `chain(n)` creates the poset with `n` elements in which $1 < 2 < 3 < \cdots < n$.
* `antichain(n)` creates the poset with `n` elements and no relations. Same as `Poset(n)`.
* `standard_example(n)` creates a poset with `2n` elements. Elements `1` through `n` form an antichain as do elements `n+1` through `2n`. The only relations are of the form `j < k` where `1 ≤ j ≤ n` and `k = n+i` where `1 ≤ i ≤ n` and `i ≠ j`. This is a smallest-size poset of dimension `n`.

> More to come


## Matrices

* `zeta_matrix(p)` returns the zeta matrix of the poset. This is a `0,1`-matrix whose
`i,j`-entry is `1` exactly when `p[i] ≤ p[j]`. 
* `mobius_matrix(p)` returns the inverse of `zeta(p)`. 

In both cases, the output is a dense, integer matrix. 


## Operations

> None implemented. Would like to see `reverse`, `+` (disjoint union), etc.