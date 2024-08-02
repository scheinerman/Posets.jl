# Posets
Partially ordered sets for Julia based on [Graphs](https://juliagraphs.org/Graphs.jl/).

## Partially Ordered Sets

A *partially ordered set*, or *poset* for short, is a pair $(V,<)$ where $V$ is a set and
$<$ is a binary relation on $V$ that satisfies these properties:
* $<$ is *irreflexive*: For all $v \in V$ it is never the case that $v<v$.
* $<$ is *antisymmetric*: For all $v,w \in V$, we never have both $v<w$ and $w<v$. 
* $<$ is *transitive*: For all $u,v,w \in V$, if $u<v$ and $v<w$ then $u<w$.