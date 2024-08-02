# Posets
Partially ordered sets for Julia based on [Graphs](https://juliagraphs.org/Graphs.jl/).

## Partially Ordered Sets

A *partially ordered set*, or *poset* for short, is a pair $(V,<)$ where $V$ is a set and
$<$ is a binary relation on $V$ that is
(a) irreflexive (for all $v \in V$ it is never the case that $v<v$),
(b) antisymmetric (for all $v,w \in V$, we never have both $v<w$ and $w<v$), and
(c) transitive (or all $u,v,w \in V$, if $u<v$ and $v<w$ then $u<w$).