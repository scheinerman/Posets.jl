using Posets, Graphs

# example 1
p = chain(3) + chain(3);
add_relation!(p, 4, 2);
rem_vertex!(p, 2);
collect(relations(p))

# example 2
p = chain(4);
rem_relation!(p, 2, 3);
collect(relations(p))

# example 3
p = chain(5);
rem_relation!(p, 2, 4);
collect(relations(p))
