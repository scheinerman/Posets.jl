# Gallery of Standard Posets

Images of some standard posets from the `Posets` module.

## `antichain(4)`

<img src="antichain.png" width="250">

## `chain(4)`

<img src="chain.png" width="40">

## `chevron()`

<img src="chevron.png" width="180">

## `crown(5,2)`

<img src="crown52.png" width="400">

## `subset_lattice(3)`

<img src="subset3.png" width="400">

```
julia> for k=1:8
       println(k," -> ",subset_decode(k))
       end
1 -> Ø
2 -> {1}
3 -> {2}
4 -> {1,2}
5 -> {3}
6 -> {1,3}
7 -> {2,3}
8 -> {1,2,3}
```


## `weak_order([1,1,1,2,2,3,3,3,3])`

<img src="weak.png" width="250">
