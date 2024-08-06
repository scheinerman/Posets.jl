"""
    _distinct(a, b, c)

Return true is `a`, `b`, and `c` are all different.
"""
_distinct(a, b, c) = (a != b) && (a != c) && (b != c)

"""
    realizer(p::Poset, d::Integer)

Return a list of `d` linear orders whose intersection is `p`,
or throw an error if not possible. 
"""
function realizer(p::Poset, d::Integer)
    n = nv(p)
    MOD = Model(get_solver())
    VV = collect(1:n)

    # x[u,v,t] == 1 means u<v in L_t

    @variable(MOD, x[u=VV, v=VV, t=1:d], Bin)

    # for all i, x[i,i,t] is zero
    for u in VV
        for t in 1:d
            @constraint(MOD, x[u, u, t] == 0)
        end
    end

    # exactly one of x[u,v,t] or x[v,u,t] is 1
    for i in 1:(n - 1)
        for j in (i + 1):n
            u = VV[i]
            v = VV[j]
            for t in 1:d
                @constraint(MOD, x[u, v, t] + x[v, u, t] == 1)
            end
        end
    end

    # if u<v x[u,v,t] == 1
    for u in VV
        for v in VV
            if p(u, v)
                for t in 1:d
                    @constraint(MOD, x[u, v, t] == 1)
                end
            end
        end
    end

    # if u and v are incomparable, sum(X[u,v,t]) > 0
    for i in 1:(n - 1)
        for j in (i + 1):n
            u = VV[i]
            v = VV[j]
            if !p(u, v) && !p(v, u)
                @constraint(MOD, sum(x[u, v, t] for t in 1:d) >= 1)
                @constraint(MOD, sum(x[v, u, t] for t in 1:d) >= 1)
            end
        end
    end

    # ensure L_t is transitive (so linear)
    for t in 1:d
        for u in VV
            for v in VV
                for w in VV
                    if _distinct(u, v, w)
                        @constraint(MOD, x[u, w, t] >= x[u, v, t] + x[v, w, t] - 1)
                    end
                end
            end
        end
    end

    optimize!(MOD)
    status = Int(termination_status(MOD))

    if status != 1
        error("This poset has dimension greater than $d; no realizer found.")
    end

    X = round.(value.(x))
    A = Int.(Array(X))
    plist = [Poset(A[:, :, k]) for k in 1:d]

    return plist
end

# """
# `dimension(P::SimplePoset, verbose=false)` returns the order-theoretic
# dimension of the poset `P`. Set `verbose` to `true` to see more information
# as the work is done.
# """

"""
    dimension(p::Poset, verb::Bool = false)::Int

Return the dimension of the poset `p`. With `verb` set to `true`, 
some information on the progress of the algorithm is printed during 
the computation. 
"""
function dimension(p::Poset, verb::Bool=false)::Int
    n = nv(p)
    if n == 0
        return 0
    end

    if 2 * nr(p) == n * (n - 1)  # it's a chain
        return 1
    end

    lb = 2

    ub1 = Int(floor(n / 2))
    ub2 = width(p)
    ub = min(ub1, ub2)

    return dimension_work(p, lb, ub, verb)
end

function dimension_work(p::Poset, lb::Int, ub::Int, verb::Bool)::Int
    if verb
        print("$lb ≤ dim(p) ≤ $ub\t")
    end

    if lb == ub
        if verb
            println("and we're done")
        end
        return lb
    end

    mid = Int(floor((ub + lb) / 2))

    if verb
        print("looking for a $mid realizer\t")
    end

    try
        R = realizer(p, mid)
        if verb
            println("confirmed")
        end
        return dimension_work(p, lb, mid, verb)
    catch
    end
    if verb
        println("none exists")
    end
    return dimension_work(p, mid + 1, ub, verb)
end
