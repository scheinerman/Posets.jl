using Posets
using Primes

function divisor_poset(nums::Vector{Int})
    if any((n <= 0 for n in nums))
        throw(ArgumentError("Numbers in the list must be postive"))
    end
    if length(unique(nums)) < length(nums)
        throw(ArgumentError("Numbers in the list must be distinct"))
    end

    n = length(nums)
    p = Poset(n)
    for i in 1:n
        a = nums[i]
        for j in 1:n
            b = nums[j]
            if mod(b, a) == 0
                add_relation!(p, i, j)
            end
        end
    end
    return p
end

"""
    divisor_poset(n::Integer)

Create a poset whose elements correspond to all the divisors of `n`
in which `a < b` provided the `a`-th divisor of `n` is a factor of the 
`b`-th divisor. 
"""
function divisor_poset(n::Integer)
    if n <= 0
        throw(ArgumentError("Number must be a postive integer"))
    end
    factors = sort(divisors(n))
    return divisor_poset(factors)
end

"""
    subsets_poset(d::Integer)

Create a poset (isomorphic to) the subsets of a `d`-element 
set ordered by inclusion. 
"""
function subsets_poset(d::Integer)
    p = prime(d)  # d'th prime 
    n = prod(primes(d))  # product of first d primes
    return divisor_poset(n)
end

nothing
