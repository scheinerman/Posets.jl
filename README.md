# Posets
Partially ordered sets for Julia based on [Graphs](https://juliagraphs.org/Graphs.jl/).

## Partially Ordered Sets

A *partially ordered set*, or *poset* for short, is a pair (V,<) where V is a set and
< is a binary relation on V that is
* irreflexive (for all v it is never the case that v<v) ,
* antisymmetric (for all v,w, we never have both $v < w$ and $w < v$ ), and
* transitive (for all $u,v,w \in V$, if $u<v$ and $v<w$ then $u<w$ ).