# Standard Posets

export chain, antichain

function chain(n::Int)::Poset{Int}
    p = Poset(n)
    for i=1:n-1
        add_relation!(p,i,i+1)
    end
    return p
end

antichain(n) = Poset(n)