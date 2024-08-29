# Posets
Partially ordered sets for Julia based on [Graphs](https://juliagraphs.org/Graphs.jl/).

## Introduction: Partially Ordered Sets

A *partially ordered set*, or *poset* for short, is a pair $(V,\prec)$ where $V$ is a set and
$\prec$ is a binary relation on $V$ that is
* *irreflexive* (for all $v \in V$, it is never the case that $v \prec v$),
* *antisymmetric* (for all $v,w \in V$, we never have both $v \prec w$ and $w \prec v$), and
* *transitive* (for all $u,v,w \in V$, if $u \prec v$ and $v \prec w$ then $u \prec w$).

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


### Adding vertices (elements)

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

### Adding a relation
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

The `add_relation!` function may also be called as `add_relation!(p, (a,b))` or 
`add_relation!(p, a => b)`. Both are equivalent to `add_relations(p, a, b)`.

### Adding multiple relations (Danger!)

The addition of a relation to a poset can be somewhat slow. 
Each addition involves error checking and calculations to ensure the integrity 
of the underlying data structure. See the Implementation section at the
end of this document.  Adding a list of relations one at a time can be inefficient,
but it is safe. We also provide the function `add_relations!` (plural) that is more 
efficient, but can cause serious problems. 

To underscore the risk, this function 
is not exported, but needs to be invoked as `Posets.add_relations!(p, rlist)` 
where `rlist` is a list of either tuples `(a,b)` or pairs `a => b`. 

Here is a good application of this function (although using `chain(10)` is safer):
```
julia> p = Poset(10)
{10, 0} Int64 poset

julia> rlist = ((i,i+1) for i=1:9)
Base.Generator{UnitRange{Int64}, var"#13#14"}(var"#13#14"(), 1:9)

julia> Posets.add_relations!(p, rlist)

julia> p == chain(10)
true
```

Here is what happens with misuse:
```
julia> p = Poset(5)
{5, 0} Int64 poset

julia> rlist = [ 1=>2, 2=>3, 3=>1 ]
3-element Vector{Pair{Int64, Int64}}:
 1 => 2
 2 => 3
 3 => 1

julia> Posets.add_relations!(p, rlist)
ERROR: This poset has been become corrupted!
```

### Removing an element

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
When element `2` is removed from `p`, element `5` takes its place. Because of this renumbering, 
we have some unexpected behavior:
```
julia> p = subset_lattice(4)
{16, 65} Int64 poset

julia> q = Poset(p)   # make a copy of p
{16, 65} Int64 poset

julia> rem_vertex!(q, 9)
true

julia> q
{15, 57} Int64 poset

julia> q ⊆ p
false

julia> maximals(p) |> collect
1-element Vector{Int64}:
 16

julia> maximals(q) |> collect
1-element Vector{Int64}:
 9
```
One might expect that deleting a vertex from a poset results in a poset that is a subset of the original. However, 
when vertex `9` was removed from (a copy of) `p`, the vertex `16` is relabeled `9`. Hence vertex `9` in `p` is
not maximal, but it is maximal in `q`. 


> For a more extensive explanation, see [poset-deletion.pdf](https://github.com/scheinerman/Posets.jl/blob/main/delete-doc/poset-deletion.pdf) in the `delete-doc` folder. 



### Removing a relation

Removing relations from a poset is accomplished with `rem_relation!(p,a,b)`. Assuming `a<b` in `p`,
this deletes the relation `a<b` from `p`, but also deletes all relations `a<x` and `x<b` for 
vertices `x` that lie between `a` and `b`.
```
julia> p = chain(5)
{5, 10} Int64 poset

julia> rem_relation!(p, 2, 4)
true

julia> collect(relations(p))
8-element Vector{Relation{Int64}}:
 Relation 1 < 2
 Relation 1 < 3
 Relation 1 < 4
 Relation 1 < 5
 Relation 2 < 4
 Relation 2 < 5
 Relation 3 < 5
 Relation 4 < 5
```
Note that relations `2<3` and `3<4` have been removed. 

> For a more extensive explanation, see [poset-deletion.pdf](https://github.com/scheinerman/Posets.jl/blob/main/delete-doc/poset-deletion.pdf) in the `delete-doc` folder. 


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
* `are_comparable(p,a,b)` returns `true` exactly when `a` and `b` are both in the poset, and one of the following is true: `a<b`, `a==b`, or `a>b`. 
* `are_incompable(p,a,b)` returns `true` exactly when `a` and `b` are both in the poset, but none of the follower are true: `a<b`, `a==b`, or `a>b`.

Alternatively, use `p[a] ⟂ p[b]` to test if `a` and `b` are comparable, and use `p[a] ∥ p[b]` to test if `a` and `b` are incomparable. 

#### Chain/antichain check

Given a list of elements `vlist` of a poset `p`:

* `is_chain(p, vlist)` returns `true` if the elements of `vlist` form a chain in `p`.
* `is_antichain(p, vlist)` returns `true` if the elements of `vlist` form an antichain in `p`.

Both return `false` if an element of `vlist` is not in `p`.


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

* `issubset(p,q)` (or `p ⊆ q`) returns `true` exactly when `nv(p) ≤ nv(q)` and whenever `v < w` in `p` we also have `v < w` in `q`.

### Above, below, between

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


### Maximals, minimals, height, and width

* `maximals(p)` returns an iterator for the maximal elements of `p`.
* `minimals(p)` returns an iterator for the minimal elements of `p`.
* `maximum(p)` returns the maximum element of `p` or `0` if no such element exists. 
* `minimum(p)` returns the minimum element of `p` or `0` if no such element exists.
* `max_chain(p)` returns a vector containing the elements of a largest chain in `p`.
* `max_antichain(p)` returns a vector containing the elements of a largest antichain in `p`.
* `height(p)` returns the size of a largest chain in `p`.
* `width(p)` returns the size of a largest antichain in `p`.
* `chain_cover(p)` returns a minimum-size collection of chains of `p` such that every element of 
   `p` is in one of the chains. The number of chains is the width of `p`. 
* `antichain_cover(p)` returns a minimum-size collection of antichains of `p` such that 
   every element of `p` is in one of the antichains. The number of antichains is the height of `p`.

   
> **Note**: The function `max_chain` returns a largest chain in the poset. It is possible that there are two or more possible answers because there are two or more such chains of maximum size. There is no guarantee as to which largest chain will be returned. Likewise for `max_antichain`. Similarly, `chain_cover` returns a minimum-size partition of the elements into chains. If there are multiple minimum-size chain covers, there is no guarantee which will be returned by `chain_cover`. Likewise for `antichain_cover`.

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

> **Note**: Computation of the dimension of a poset is NP-hard. The `dimension` function may be slow, even for moderate-size posets.


## Standard Posets

The following functions create standard partially ordered sets. 
See the [Gallery](https://github.com/scheinerman/Posets.jl/blob/main/gallery/README.md) 
for pictures of some of these posets.

* `antichain(n)` creates the poset with `n` elements and no relations. Same as `Poset(n)`.

* `chain(n)` creates the poset with `n` elements in which `1 < 2 < 3 < ... < n`. 
  
* `chain(vlist)` creates a chain from the integer vector `vlist` (which must be a permutation of `1:n`). For example, `chain([2,1,3])` creates a chain in which `2 < 1 < 3`.

* `chevron()` creates a poset with `6` elements that has dimension equal to `3`. It is 
  different from `standard_example(3)`. 

* `crown(n,k)` creates the crown poset with `2n` elements with two levels: `n` elements as minimals
  and `n` as maximals. Each minimal is comparable to `n-k` maximals. See the help message for more information.

* `random_linear_order(n)`: Create a linear order in which the numbers `1` through `n` 
  appear in random order.

* `random_poset(n,d=2)`: Create a random `d`-dimensional poset by intersecting `d` random linear orders,
  each with `n` elements. 

* `standard_example(n)` creates a poset with `2n` elements. Elements `1` through `n` form an antichain 
  as do elements `n+1` through `2n`. The only relations are of the form `j < k` where `1 ≤ j ≤ n` 
  and `k = n+i` where `1 ≤ i ≤ n` and `i ≠ j`. This is a smallest-size poset of dimension `n`.
  Equivalent to `crown(n,1)`.

* `subset_lattice(d)`: Create the poset corresponding to the `2^d` subsets of `{1,2,...,d}` 
  ordered by inclusion. For `a` between `1` and `2^d`, element `a` corresponds to a 
  subset of `{1,2,...,d}` as follows: Write `a-1` in binary and view the bits as the characteristic 
  vector indicating the members of the set. For example, if `a` equals `12`, then `a-1` is `1011` in 
  binary. Reading off the digits from the right, this gives the set `{1,2,4}`.  
  * Use `subset_decode(a)` to convert an element `a` of this poset into a set of positive integers, `A`.
  * Use `subset_encode(A)` to convert a set of positive integers to its name in this poset. 

* `weak_order(vals)`: Create a weak order `p` from a list of real numbers. In `p` element `i` is less than element `j` provided `vals[i] < vals[j]` .

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
* `strict_zeta_matrix(p)` returns a  `0,1`-matrix whose `i,j` entry is `1` 
  exactly when `p[i] < p[j]`.
* `mobius_matrix(p)` returns the inverse of `zeta(p)`. 

In all cases, the output is a dense, integer matrix. 


## Operations

### Dual
The dual of poset `p` is created using `reverse(p)`. This returns a new poset with the
same elements as `p` in which all relations are reversed (i.e., `v < w` in `p` if and 
only if `w < v` in `reverse(p)`). The dual (reverse) of `p` can also be created with `p'`. 

### Disjoint union
Given two posets `p` and `q`, the result of `p+q` is a new poset formed from the 
disjoint union of `p` and `q`. Note that `p+q` and `q+p` are isomorphic, but 
may be unequal because of the vertex numbering convention. 

Alternatively `hcat(p,q)`.

### Stack

Given two posets `p` and `q`, the result of `p/q` is a new poset from a copy of `p` 
and a copy of `q` with all elements of `p` above all elements of `q`. 

Alternatively, `vcat(p,q)` or  `q\p`.

### Cartesian product 

Given posets $P$ and $Q$, their *Cartesian product*, $P \times Q$, is a poset whose 
elements are all ordered pairs $(a,b)$ where $a$ is an element of $P$ and $b$ is an element
of $Q$. In this poset we have $(a,b)\preceq(c,d)$ if and only if $a\preceq c$ in $P$ and 
$b\preceq d$ in $Q$.

Cartesian product is implemented in `Posets` as `p * q`. The result is a new poset 
that is isomorphic to the Cartesian product of `p` and `q`. 

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

### Join and meet

Let $x$ and $y$ be elements of a poset $P$. 
Let $U$ be the set of all elements $z$ of $P$ such that $x \preceq z$ and $y \preceq z$. 
This is the set of all elements above or equal to both $x$ and $y$. 
If $U$ contains a minimum element (one that is below all the other elements of $U$), 
then that minimum element $u$ is the *join* of $x$ and $y$. Notation $u = x \vee y$. 

Similarly, let $D$ be the set of all elements $z$ of $P$ such that 
$z \preceq x$ and $z \preceq y$. This is the set of all
elements in $P$ that are below or equal to $x$ and $y$. If $D$ contains a unique maximum element
(one that is above all the other elements in $D$), then that maximum element $d$ is the 
*meet* of $x$ and $y$. Notation: $d = x \wedge y$. 

There are two ways to compute the join [or meet] of elements in a poset. 

* The join and meet of elements `x` and `y` in poset `p` can be computed as `p[x] ∨ p[y]` and `p[x] ∧ p[y]`.
* Or use the functions `lattice_join(p,x,y)` or `lattice_meet(p,x,y)`


**Important notes**:
* The meet [or join] of two elements need not exist.
  * In the operation form, `p[x] ∧ p[y]` [or `p[x] ∨ p[y]`], if there is no meet [or join], an error is thrown.
  * In the function form, `lattice_meet(p,x,y)` [or `lattice_join(x,y)`], if there is no meet [or join] then `0` is returned. 
* Cannot compute the meet [or join] of elements in different posets. 
* The expression `p[x]` throws an error if `x` is not an element of `p`. 
* The symbol `∨` is typed `\vee<TAB>` and `∧` is typed `\wedge<TAB>`.
* The result of `p[x] ∨ p[y]` is an object of type `PosetElement` (likewise for `∧`). 
* The result of `lattice_join` [or `lattice_meet`] is always an integer. The return value of `0` is used to show that the join [or meet] does not exist. 

The join and meet operations for posets are analogous to union and intersection for sets as illustrated here:
```
julia> using ShowSet

julia> p = subset_lattice(4)
{16, 65} Int64 poset

julia> A = Set([1,2,3])
{1,2,3}

julia> B = Set([2,3,4])
{2,3,4}

julia> a = subset_encode(A)
8

julia> b = subset_encode(B)
15

julia> p[a] ∨ p[b]
Element 16 in a {16, 65} Int64 poset

julia> subset_decode(integer(ans))
{1,2,3,4}

julia> p[a] ∧ p[b]
Element 7 in a {16, 65} Int64 poset

julia> subset_decode(integer(ans))
{2,3}
```

Further, the function `join_table(p)` [or `meet_table`] creates a matrix 
whose `i,j`-entry is the join [or meet] of elements `i` and `j` in poset `p`, 
or `0` if the join [or meet] doesn't exist.



## Implementation

A `Poset` is a structure that contains a single data element: a `DiGraph`. 
Users should not be accessing this directly, but it may be useful to understand
how posets are implemented. The directed graph is acyclic (including loopless)
and transitively closed. This means if $a \to b$ is an edge and $b\to c$ is
an edge, then $a \to c$ is also an edge. The advantage to this structure is that
checking if $a \prec b$ in a poset is quick. There are two disadvantages.

First, the graph may be larger than needed. If we only kept cover edges 
(the transitive reduction of the digraph) we might have many fewer edges. 
For example, a linear order with $n$ elements has $\binom{n}{2} \sim n^2/2$ 
edges in the digraph that represents it, whereas there are only $n-1$ edges in 
the cover digraph. However, this savings is an extreme example. A poset with $n$
elements split into two antichains, with every element of the first antichain below
every element of the second, has $n^2/4$ edges in either representation. 
So in either case, the representing digraph may have up to order $n^2$ edges. 

Second, the computational cost of adding (or deleting) a relation is nontrivial. 
The `add_relation!` function first checks if the added relation would violate 
transitivity; this is speedy because we can add the relation $a \prec b$ so 
long as we don't have $b\prec a$ already in the poset. However, after the edge $(a,b)$ 
is inserted into the digraph, we execute `transitiveclosure!` and that takes some 
work. Adding several relations to the poset, one at a time, can be slow. 

This can be greatly accelerated by using `Posets.add_relations!` but (as discussed above)
this function can cause severe problems if not used carefully.



## See Also

The `extras` folder includes additional code that may be useful in 
working with `Posets`. See the `README` in the `extras` directory. 

Of note is `extras/converter.jl` that defines the function `poset_converter` that can 
be used to transform a `Poset` (defined in this module) to a `SimplePoset` 
(defined in the [SimplePosets](https://github.com/scheinerman/SimplePosets.jl) module). 


