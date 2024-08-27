var documenterSearchIndex = {"docs":
[{"location":"#Posets","page":"Posets","title":"Posets","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Partially ordered sets for Julia based on Graphs.","category":"page"},{"location":"#Introduction:-Partially-Ordered-Sets","page":"Posets","title":"Introduction: Partially Ordered Sets","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"A partially ordered set, or poset for short, is a pair (Vprec) where V is a set and prec is a binary relation on V that is","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"irreflexive (for all v in V, it is never the case that v prec v),\nantisymmetric (for all vw in V, we never have both v prec w and w prec v), and\ntransitive (for all uvw in V, if u prec v and v prec w then u prec w).","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Posets are naturally represented as transitively closed, directed, acyclic graphs. This is how this module implements posets using the DiGraph type in Graphs.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The design philosophy for this module is modeled exactly on Graphs. In particular, the vertex set of a poset is necessarily of the form {1,2,...,n}.","category":"page"},{"location":"#Basics","page":"Posets","title":"Basics","text":"","category":"section"},{"location":"#Construct-new-posets","page":"Posets","title":"Construct new posets","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Create a new poset with no elements using Poset() or a poset with a specified number  of elements with Poset(n). ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Given a poset p, use Poset(p) to create an independent copy of p.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Given a directed graph d, use Poset(d) to create a new poset from the transitive  closure of d. An error is thrown if d has cycles. (Self loops in d are ignored.)","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Given a square matrix A, create a poset in which i < j exactly when the i,j-entry  of A is nonzero. Diagonal entries are ignored. If this matrix would create a cycle, an  error is thrown. ","category":"page"},{"location":"#Adding-vertices-(elements)","page":"Posets","title":"Adding vertices (elements)","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"For consistency with Graph, we call the elements of a Poset vertices and the functions add_vertex! and add_vertices! work exactly as in the Graphs module.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> using Posets\n\njulia> p = Poset()\n{0, 0} Int64 poset\n\njulia> add_vertex!(p)\ntrue\n\njulia> add_vertices!(p,5)\n5\n\njulia> p\n{6, 0} Int64 poset","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Use nv(p) to return the number of elements (vertices) in p.","category":"page"},{"location":"#Adding-a-relation","page":"Posets","title":"Adding a relation","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"To add a relation to a poset, use add_relation!. This returns true when successful.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = Poset(4)\n{4, 0} Int64 poset\n\njulia> add_relation!(p,1,2)\ntrue\n\njulia> add_relation!(p,2,3)\ntrue\n\njulia> add_relation!(p,3,1)\nfalse","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Let's look at this carefully to understand why the third call to add_relation! does not succeed:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The first call to add_relation! causes the relation 1 < 2 to hold in p. \nThe second call to add_relation! causes the relation 2 < 3 to be added to p. Given that 1 < 2 and 2 < 3, by transitivity we automatically have 1 < 3 in p.\nTherefore, we cannot add 3 < 1 as a relation to this poset as that would violate antisymmetry.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The add_relation! function may also be called as add_relation!(p, (a,b)) or  add_relation!(p, a => b). Both are equivalent to add_relations(p, a, b).","category":"page"},{"location":"#Adding-multiple-relations-(Danger!)","page":"Posets","title":"Adding multiple relations (Danger!)","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"The addition of a relation to a poset can be somewhat slow.  Each addition involves error checking and calculations to ensure the integrity  of the underlying data structure. See the Implementation section at the end of this document.  Adding a list of relations one at a time can be inefficient, but it is safe. We also provide the function add_relations! (plural) that is more  efficient, but can cause serious problems. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"To underscore the risk, this function  is not exported, but needs to be invoked as Posets.add_relations!(p, rlist)  where rlist is a list of either tuples (a,b) or pairs a => b. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Here is a good application of this function (although using chain(10) is safer):","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = Poset(10)\n{10, 0} Int64 poset\n\njulia> rlist = ((i,i+1) for i=1:9)\nBase.Generator{UnitRange{Int64}, var\"#13#14\"}(var\"#13#14\"(), 1:9)\n\njulia> Posets.add_relations!(p, rlist)\n\njulia> p == chain(10)\ntrue","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Here is what happens with misuse:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = Poset(5)\n{5, 0} Int64 poset\n\njulia> rlist = [ 1=>2, 2=>3, 3=>1 ]\n3-element Vector{Pair{Int64, Int64}}:\n 1 => 2\n 2 => 3\n 3 => 1\n\njulia> Posets.add_relations!(p, rlist)\nERROR: This poset has been become corrupted!","category":"page"},{"location":"#Removing-an-element","page":"Posets","title":"Removing an element","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"The function rem_vertex! behaves exactly as in Graphs. It removes the given vertex from the poset. For example:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = Poset(5)\n{5, 0} Int64 poset\n\njulia> add_relation!(p,1,5)\ntrue\n\njulia> rem_vertex!(p,2)\ntrue\n\njulia> has_relation(p,1,2)\ntrue","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"When element 2 is removed from p, element 5 takes its place. Because of this renumbering,  we have some unexpected behavior:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = subset_lattice(4)\n{16, 65} Int64 poset\n\njulia> q = Poset(p)   # make a copy of p\n{16, 65} Int64 poset\n\njulia> rem_vertex!(q, 9)\ntrue\n\njulia> q\n{15, 57} Int64 poset\n\njulia> q ⊆ p\nfalse\n\njulia> maximals(p) |> collect\n1-element Vector{Int64}:\n 16\n\njulia> maximals(q) |> collect\n1-element Vector{Int64}:\n 9","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"One might expect that deleting a vertex from a poset results in a poset that is a subset of the original. However,  when vertex 9 was removed from (a copy of) p, the vertex 16 is relabeled 9. Hence vertex 9 in p is not maximal, but it is maximal in q. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"For a more extensive explanation, see poset-deletion.pdf in the delete-doc folder. ","category":"page"},{"location":"#Removing-a-relation","page":"Posets","title":"Removing a relation","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Removing relations from a poset is accomplished with rem_relation!(p,a,b). Assuming a<b in p, this deletes the relation a<b from p, but also deletes all relations a<x and x<b for  vertices x that lie between a and b.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = chain(5)\n{5, 10} Int64 poset\n\njulia> rem_relation!(p, 2, 4)\ntrue\n\njulia> collect(relations(p))\n8-element Vector{Relation{Int64}}:\n Relation 1 < 2\n Relation 1 < 3\n Relation 1 < 4\n Relation 1 < 5\n Relation 2 < 4\n Relation 2 < 5\n Relation 3 < 5\n Relation 4 < 5","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Note that relations 2<3 and 3<4 have been removed. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"For a more extensive explanation, see poset-deletion.pdf in the delete-doc folder. ","category":"page"},{"location":"#Inspection","page":"Posets","title":"Inspection","text":"","category":"section"},{"location":"#Vertices","page":"Posets","title":"Vertices","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Use nv(p) to return the number of vertices in the poset p. As in Graphs, the  elements of the poset are integers from 1 to n. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Use in(a, p) [or a ∈ p] to determine if a is an element of p.  This is equivalent to 1 <= a <= nv(p).","category":"page"},{"location":"#Relations","page":"Posets","title":"Relations","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"There are three ways to check if elements are related in a poset.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"First, to see if  1 < 3 in p we use the has_relation function:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> has_relation(p,1,3)\ntrue","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Second, the syntax p(a,b) is equivalent to has_relation(p,a,b):","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p(1,3)\ntrue\n\njulia> p(3,1)\nfalse","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"There is a third way to determine the relation between elements a and b in a poset p. Instead of has_relation(p,a,b) or p(a,b) we may use this instead: p[a] < p[b].","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> has_relation(p,1,3)\ntrue\n\njulia> p[1] < p[3]\ntrue\n\njulia> p[3] < p[1]\nfalse","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The other comparison operators (<=, >, >=, ==, !=) works as expected.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p[3] > p[1]\ntrue","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Neither has_relation(p,a,b) nor p(a,b) generate errors; they return false  even if a or b are not elements of p. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p(-2,9)\nfalse","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"However, the expression p[a] < p[b]  throws an error in either of these situations:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Using the syntax p[a] if a is not an element of p.\nTrying to compare elements of different posets (even if the two posets are equal).","category":"page"},{"location":"#Comparability-check","page":"Posets","title":"Comparability check","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"The functions are_comparable(p,a,b) and are_incomparable(p,a,b) behave as follows:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"are_comparable(p,a,b) returns true exactly when a and b are both in the poset, and one of the following is true: a<b, a==b, or a>b. \nare_incompable(p,a,b) returns true exactly when a and b are both in the poset, but none of the follower are true: a<b, a==b, or a>b.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Alternatively, use p[a] ⟂ p[b] to test if a and b are comparable, and use p[a] ∥ p[b] to test if a and b are incomparable. ","category":"page"},{"location":"#Chain/antichain-check","page":"Posets","title":"Chain/antichain check","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Given a list of elements vlist of a poset p:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"is_chain(p, vlist) returns true if the elements of vlist form a chain in p.\nis_antichain(p, vlist) returns true if the elements of vlist form an antichain in p.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Both return false if an element of vlist is not in p.","category":"page"},{"location":"#Counting/listing-relations","page":"Posets","title":"Counting/listing relations","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Use nr to return the number of relations in the poset (this is analogous to ne in Graphs):","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> nr(p)\n3","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The function relations returns an iterator for all the relations in a poset.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = chain(4)\n{4, 6} Int64 poset\n\njulia> collect(relations(p))\n6-element Vector{Relation{Int64}}:\n Relation 1 < 2\n Relation 1 < 3\n Relation 1 < 4\n Relation 2 < 3\n Relation 2 < 4\n Relation 3 < 4","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The functions src and dst return the lesser and greater elements of a relation, respectively:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> r = first(relations(p))\nRelation 1 < 2\n\njulia> src(r), dst(r)\n(1, 2)","category":"page"},{"location":"#Subset","page":"Posets","title":"Subset","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"issubset(p,q) (or p ⊆ q) returns true exactly when nv(p) ≤ nv(q) and whenever v < w in p we also have v < w in q.","category":"page"},{"location":"#Above,-below,-between","page":"Posets","title":"Above, below, between","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"above(p,a) returns an iterator for all elements k of p such that a<k.\nbelow(p,a) returns an iterator for all elements k of p such that k<a.\nbetween(p,a,b) returns an iterator for all elements k of p such that a<k<b.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = chain(10)\n{10, 45} Int64 poset\n\njulia> collect(above(p,6))\n4-element Vector{Int64}:\n  7\n  8\n  9\n 10\n\njulia> collect(below(p,6))\n5-element Vector{Int64}:\n 1\n 2\n 3\n 4\n 5\n\njulia> collect(between(p,3,7))\n3-element Vector{Int64}:\n 4\n 5\n 6","category":"page"},{"location":"#Covers","page":"Posets","title":"Covers","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"In a poset, we say a is covered by b provided a < b and there is no element c such  that a < c < b.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Use covered_by(p,a,b) to determine if a is covered by b. Alternatively, use p[a] << p[b] or p[b] >> p[a].","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = chain(8)\n{8, 28} Int64 poset\n\njulia> p[4] << p[5]\ntrue\n\njulia> p[4] << p[6]\nfalse","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The functions just_above and just_below can be used to find elements that cover, or are covered by, a given vertex.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = chain(9)\n{9, 36} Int64 poset\n\njulia> above(p,5) |> collect\n4-element Vector{Int64}:\n 6\n 7\n 8\n 9\n\njulia> just_above(p,5) |> collect\n1-element Vector{Int64}:\n 6\n\njulia> below(p,5) |> collect\n4-element Vector{Int64}:\n 1\n 2\n 3\n 4\n\njulia> just_below(p,5) |> collect\n1-element Vector{Int64}:\n 4","category":"page"},{"location":"#Maximals,-minimals,-height,-and-width","page":"Posets","title":"Maximals, minimals, height, and width","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"maximals(p) returns an iterator for the maximal elements of p.\nminimals(p) returns an iterator for the minimal elements of p.\nmaximum(p) returns the maximum element of p or 0 if no such element exists. \nminimum(p) returns the minimum element of p or 0 if no such element exists.\nmax_chain(p) returns a vector containing the elements of a largest chain in p.\nmax_antichain(p) returns a vector containing the elements of a largest antichain in p.\nheight(p) returns the size of a largest chain in p.\nwidth(p) returns the size of a largest antichain in p.\nchain_cover(p) returns a minimum-size collection of chains of p such that every element of   p is in one of the chains. The number of chains is the width of p. \nantichain_cover(p) returns a minimum-size collection of antichains of p such that   every element of p is in one of the antichains. The number of antichains is the height of p.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Note: The function max_chain returns a largest chain in the poset. It is possible that there are two or more possible answers because there are two or more such chains of maximum size. There is no guarantee as to which largest chain will be returned. Likewise for max_antichain. Similarly, chain_cover returns a minimum-size partition of the elements into chains. If there are multiple minimum-size chain covers, there is no guarantee which will be returned by chain_cover. Likewise for antichain_cover.","category":"page"},{"location":"#Isomorphism","page":"Posets","title":"Isomorphism","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"For posets p and q, use iso(p,q) to compute an isomorphism from p to q,  or throw an error if the posets are not isomorphic.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Let f = iso(p,q). Then f is a Dict mapping vertices of p to vertices of q.  For example, if p has a unique minimal element x, then f[x] is the unique minimal element of q. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"To check if posets are isomorphic, use iso_check (which calls iso inside a try/catch block).","category":"page"},{"location":"#Realizers-and-dimension","page":"Posets","title":"Realizers and dimension","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"A realizer for a poset p is a set of linear extensions whose intersection is p.  The function realizer(p, d) returns a list of d linear extensions (total orders)  that form a realizer of p, or throws an error if no realizer of that size exists.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = standard_example(3)\n{6, 6} Int64 poset\n\njulia> r = realizer(p, 3)\n3-element Vector{Poset{Int64}}:\n {6, 15} Int64 poset\n {6, 15} Int64 poset\n {6, 15} Int64 poset\n\njulia> r[1] ∩ r[2] ∩ r[3] == p\ntrue\n\njulia> realizer(p, 2)\nERROR: This poset has dimension greater than 2; no realizer found.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The dimension of a poset is the size of a smallest realizer. Use dimension(p)  to calculate its dimension. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = standard_example(4)\n{8, 12} Int64 poset\n\njulia> dimension(p)\n4","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Note: Computation of the dimension of a poset is NP-hard. The dimension function may be slow, even for moderate-size posets.","category":"page"},{"location":"#Standard-Posets","page":"Posets","title":"Standard Posets","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"The following functions create standard partially ordered sets.  See the Gallery  for pictures of some of these posets.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"antichain(n) creates the poset with n elements and no relations. Same as Poset(n).\nchain(n) creates the poset with n elements in which 1 < 2 < 3 < ... < n. \nchain(vlist) creates a chain from the integer vector vlist (which must be a permutation of 1:n). For example, chain([2,1,3]) creates a chain in which 2 < 1 < 3.\nchevron() creates a poset with 6 elements that has dimension equal to 3. It is  different from standard_example(3). \ncrown(n,k) creates the crown poset with 2n elements with two levels: n elements as minimals and n as maximals. Each minimal is comparable to n-k maximals. See the help message for more information.\nrandom_linear_order(n): Create a linear order in which the numbers 1 through n  appear in random order.\nrandom_poset(n,d=2): Create a random d-dimensional poset by intersecting d random linear orders, each with n elements. \nstandard_example(n) creates a poset with 2n elements. Elements 1 through n form an antichain  as do elements n+1 through 2n. The only relations are of the form j < k where 1 ≤ j ≤ n  and k = n+i where 1 ≤ i ≤ n and i ≠ j. This is a smallest-size poset of dimension n. Equivalent to crown(n,1).\nsubset_lattice(d): Create the poset corresponding to the 2^d subsets of {1,2,...,d}  ordered by inclusion. For a between 1 and 2^d, element a corresponds to a  subset of {1,2,...,d} as follows: Write a-1 in binary and view the bits as the characteristic  vector indicating the members of the set. For example, if a equals 12, then a-1 is 1011 in  binary. Reading off the digits from the right, this gives the set {1,2,4}.  \nUse subset_decode(a) to convert an element a of this poset into a set of positive integers, A.\nUse subset_encode(A) to convert a set of positive integers to its name in this poset. \nweak_order(vals): Create a weak order p from a list of real numbers. In p element i is less than element j provided vals[i] < vals[j] .","category":"page"},{"location":"#Graphs","page":"Posets","title":"Graphs","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Let p be a poset. The following two functions create graphs from p with the same  vertex set as p:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"comparability_graph(p) creates an undirected graph in which there is an edge from v to w exactly when v < w or w < v in p.\ncover_digraph(p) creates a directed graph in which there is an edge from v to w exactly when v is covered by w.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = chain(9)\n{9, 36} Int64 poset\n\njulia> g = comparability_graph(p)\n{9, 36} undirected simple Int64 graph\n\njulia> g == complete_graph(9)\ntrue\n\njulia> d = cover_digraph(p)\n{9, 8} directed simple Int64 graph\n\njulia> d == path_digraph(9)\ntrue","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Given a graph g, calling vertex_edge_incidence_poset(p) creates a poset whose elements correspond to the vertices and edges of g. In this poset the only relations are of the form v < e where v is a vertex that is an end point of the edge e.","category":"page"},{"location":"#Matrices","page":"Posets","title":"Matrices","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"zeta_matrix(p) returns the zeta matrix of the poset. This is a 0,1-matrix whose i,j-entry is 1 exactly when p[i] ≤ p[j]. \nstrict_zeta_matrix(p) returns a  0,1-matrix whose i,j entry is 1  exactly when p[i] < p[j].\nmobius_matrix(p) returns the inverse of zeta(p). ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"In all cases, the output is a dense, integer matrix. ","category":"page"},{"location":"#Operations","page":"Posets","title":"Operations","text":"","category":"section"},{"location":"#Dual","page":"Posets","title":"Dual","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"The dual of poset p is created using reverse(p). This returns a new poset with the same elements as p in which all relations are reversed (i.e., v < w in p if and  only if w < v in reverse(p)). The dual (reverse) of p can also be created with p'. ","category":"page"},{"location":"#Disjoint-union","page":"Posets","title":"Disjoint union","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Given two posets p and q, the result of p+q is a new poset formed from the  disjoint union of p and q. Note that p+q and q+p are isomorphic, but  may be unequal because of the vertex numbering convention. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Alternatively hcat(p,q).","category":"page"},{"location":"#Stack","page":"Posets","title":"Stack","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Given two posets p and q, the result of p/q is a new poset from a copy of p  and a copy of q with all elements of p above all elements of q. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Alternatively, vcat(p,q) or  q\\p.","category":"page"},{"location":"#Induced-subposet","page":"Posets","title":"Induced subposet","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Given a poset p and a list of vertices vlist, use induced_subposet(p) to return a  pair (q,vmap). The poset q is the induced subposet and the vector vmap maps the new vertices to the old ones  (the vertex i in the subposet corresponds to the vertex vmap[i] in p).","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"This is exactly analogous to Graphs.induced_subgraph. ","category":"page"},{"location":"#Intersection","page":"Posets","title":"Intersection","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Given two posets p and q, intersect(p,q) is a new poset in which v < w if and only  if v < w in both p and q. The number of elements is the smaller of nv(p) and nv(q). This may also be invoked as p ∩ q. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"For example, the intersection of a chain with its reversal has no relations:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> p = chain(5)\n{5, 10} Int64 poset\n\njulia> p ∩ reverse(p)\n{5, 0} Int64 poset","category":"page"},{"location":"#Linear-extension","page":"Posets","title":"Linear extension","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Use linear_extension(p) to create  a linear extension of p.  This is a total order q with the same elements as p and with p ⊆ q. ","category":"page"},{"location":"#Join-and-meet","page":"Posets","title":"Join and meet","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"Let x and y be elements of a poset P.  Let U be the set of all elements z of P such that x preceq z and y preceq z.  This is the set of all elements above or equal to both x and y.  If U contains a minimum element (one that is below all the other elements of U),  then that minimum element u is the join of x and y. Notation u = x vee y. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Similarly, let D be the set of all elements z of P such that  z preceq x and z preceq y. This is the set of all elements in P that are below or equal to x and y. If D contains a unique maximum element (one that is above all the other elements in D), then that maximum element d is the  meet of x and y. Notation: d = x wedge y. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"In this module, the join and meet of elements x and y in poset p can be computed as  p[x] ∨ p[y] and p[x] ∧ p[y]. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Important notes:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The meet [or join] of two elements need not exist. If there is no meet [or join], an error is thrown.\nCannot compute the meet [or join] of elements in different posets. \nThe expression p[x] throws an error if x is not an element of p. \nThe symbol ∨ is typed \\vee<TAB> and ∧ is typed \\wedge<TAB>.\nThe result of p[x] ∨ p[y] is an object of type PosetElement (likewise for meet). To convert this back to an integer, wrap the result in integer. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"The join and meet operations for posets are analogous to union and intersection for sets as illustrated here:","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"julia> using ShowSet\n\njulia> p = subset_lattice(4)\n{16, 65} Int64 poset\n\njulia> A = Set([1,2,3])\n{1,2,3}\n\njulia> B = Set([2,3,4])\n{2,3,4}\n\njulia> a = subset_encode(A)\n8\n\njulia> b = subset_encode(B)\n15\n\njulia> p[a] ∨ p[b]\nElement 16 in a {16, 65} Int64 poset\n\njulia> subset_decode(integer(ans))\n{1,2,3,4}\n\njulia> p[a] ∧ p[b]\nElement 7 in a {16, 65} Int64 poset\n\njulia> subset_decode(integer(ans))\n{2,3}","category":"page"},{"location":"#Implementation","page":"Posets","title":"Implementation","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"A Poset is a structure that contains a single data element: a DiGraph.  Users should not be accessing this directly, but it may be useful to understand how posets are implemented. The directed graph is acyclic (including loopless) and transitively closed. This means if a to b is an edge and bto c is an edge, then a to c is also an edge. The advantage to this structure is that checking if a prec b in a poset is quick. There are two disadvantages.","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"First, the graph may be larger than needed. If we only kept cover edges  (the transitive reduction of the digraph) we might have many fewer edges.  For example, a linear order with n elements has binomn2 sim n^22  edges in the digraph that represents it, whereas there are only n-1 edges in  the cover digraph. However, this savings is an extreme example. A poset with n elements split into two antichains, with every element of the first antichain below every element of the second, has n^24 edges in either representation.  So in either case, the representing digraph may have up to order n^2 edges. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Second, the computational cost of adding (or deleting) a relation is nontrivial.  The add_relation! function first checks if the added relation would violate  transitivity; this is speedy because we can add the relation a prec b so  long as we don't have bprec a already in the poset. However, after the edge (ab)  is inserted into the digraph, we execute transitiveclosure! and that takes some  work. Adding several relations to the poset, one at a time, can be slow. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"This can be greatly accelerated by using Posets.add_relations! but (as discussed above) this function can cause severe problems if not used carefully.","category":"page"},{"location":"#See-Also","page":"Posets","title":"See Also","text":"","category":"section"},{"location":"","page":"Posets","title":"Posets","text":"The extras folder includes additional code that may be useful in  working with Posets. See the README in the extras directory. ","category":"page"},{"location":"","page":"Posets","title":"Posets","text":"Of note is extras/converter.jl that defines the function poset_converter that can  be used to transform a Poset (defined in this module) to a SimplePoset  (defined in the SimplePosets module). ","category":"page"}]
}
