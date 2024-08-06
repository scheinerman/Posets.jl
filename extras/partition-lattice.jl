using Graphs
using Posets
using SimplePartitions

"""
    partition_lattice(n::Integer)

Return the pair `(p, tab)` where 
* `p` is the partition lattice of all `n`-sets ordered by refinement. The least 
  element corresponds to the partition `{{1},{2},...,{n}}` and the largest element 
  corresponds to `{{1,2,...,n}}`
* `tab` is a table of the partitions. In this way element `a` of `p` corresponds to the
  partition `tab[a]`.
"""
function partition_lattice(n::Integer)
    ptns = collect(all_partitions(n))
    n = length(ptns)
    g = DiGraph(n)

    for a in 1:n
        A = ptns[a]
        for b in 1:n
            B = ptns[b]
            if (A != B) && refines(A, B)
                add_edge!(g, a, b)
            end
        end
    end

    return Poset(g), ptns
end

"""
    partition_lattice_demo(n::Int)

Print out a maximum chain in `partition_lattice(n)`. Recommend `using ShowSet` before using. 
"""
function partition_lattice_demo(n::Int)
    p, tab = partition_lattice(n)
    ch = max_chain(p)
    nch = length(ch)

    for j in 1:nch
        print(tab[ch[j]])
        if j < nch
            print(" < ")
        else
            println()
        end
    end
end

nothing
