"""
    above(p::Poset, a::Integer)

Return an iterator for all elements `k` such that `a < k`.
"""
function above(p::Poset, a::Integer)
    return (k for k in 1:nv(p) if p(a, k))
end

"""
    below(p::Poset, a::Integer)

Return an iterator for all elements `k` such that `k < a`.
"""
function below(p::Poset, a::Integer)
    return (k for k in 1:nv(p) if p(k, a))
end

"""
    between(p::Poset, a::Integer, b::Integer)

Return an iterator for all elements `k` such that `a < k < b`.
"""
function between(p::Poset, a::Integer, b::Integer)
    return (k for k in 1:nv(p) if p(a, k) && p(k, b))
end
