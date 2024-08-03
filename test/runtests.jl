using Test
using Posets
using LinearAlgebra

@testset "Basics" begin
    p = Poset(5)
    @test nv(p) == 5
    add_vertex!(p)
    @test nv(p) == 6
    add_vertices!(p, 4)
    @test nv(p) == 10

    add_relation!(p, 1, 2)
    add_relation!(p, 2, 3)
    @test nr(p) == 3

    @test has_relation(p, 1, 3)
    @test p(1, 3)
    @test p[1] < p[3]
    @test p[3] > p[1]

    rem_vertex!(p, 2)
    @test nr(p) == 1
    @test p[1] < p[3]
    @test p[3] >= p[1]

    @test length(relations(p)) == ne(p.d)
end

@testset "Above/Below/Between" begin
    p = chain(8)
    @test collect(above(p, 5)) == [6, 7, 8]
    @test collect(below(p, 5)) == [1, 2, 3, 4]
    @test collect(between(p, 1, 5)) == [2, 3, 4]

    @test collect(just_above(p, 5)) == [6]
    @test collect(just_below(p, 5)) == [4]

    @test p[4] << p[5]
    @test !(p[4] >> p[2])

    @test collect(minimals(p)) == [1]
    @test collect(maximals(p)) == [nv(p)]

    p = standard_example(5)
    @test collect(maximals(p)) == collect(6:10)
    @test collect(minimals(p)) == collect(1:5)
end

@testset "Operations" begin
    p = reverse(chain(3))
    q = p / p
    @test q == reverse(chain(6))

    p = antichain(4) / chain(3) / antichain(2)
    @test length(collect(maximals(p))) == 4
    @test length(collect(minimals(p))) == 2

    p = chain(3) + chain(2)
    @test length(collect(maximals(p))) == 2

    p = chain(5) ∩ reverse(chain(5))
    @test nr(p) == 0
end

@testset "Matrices" begin
    p = chain(3) + chain(5)
    A = zeta_matrix(p)
    @test sum(diag(A)) == 8
    q = Poset(A')
    @test p == reverse(q)
    @test A * mobius_matrix(p) == I
end

@testset "Graphs" begin
    p = chain(3) / antichain(4)
    g = cover_digraph(p)
    @test ne(g) == 6
    @test nv(g) == 7
    @test is_tree(Graph(g))


    p = chain(3) + chain(4)
    g = comparability_graph(p)
    @test length(connected_components(g)) == 2
end