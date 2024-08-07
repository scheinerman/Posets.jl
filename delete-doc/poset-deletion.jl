using Posets, Graphs


# example 1
p = chain(3) + chain(3);
add_relation!(p, 4, 2);
rem_vertex!(p, 2);
collect(relations(p))


# example 2
p = chain(4);
g = DiGraph(p.d); # This makes a copy of the graph 
rem_edge!(g, 3, 4);
q = Poset(g);
collect(relations(q))


# example 3
p = chain(5);
g = DiGraph(p.d);
