using TreeView
using LightGraphs
using Test

# write your own tests here
@testset "@tree" begin

    t = @tree 1x

    @test isa(t, TreeView.LabelledTree)
    @test isa(t.g, LightGraphs.DiGraph)
    @test isa(t.labels, Vector{Any})

    @test vertices(t.g) == collect(1:3)
    @test t.labels == Any[:*,1,:x]


    t = @tree x^2 + y^2
    @test length(t.labels) == 7
end

@testset "latex special characters" begin
    # Test for issues with the characters present in julia's generated symbols
    expr = Expr(Symbol("##271"))
    t = walk_tree(expr)
    @test t.labels[1] == Symbol("##271")

    t = @tree x && y
    @test TreeView.latex_escape(string(t.labels[1])) == "\\&\\&"
end

@testset "DAG" begin
    dag = @dag x + 2x
    @test length(dag.labels) == 4

    dag = @dag((x+y)^2 + (x+y))
    @test length(dag.labels) == 7

    dag2 = @dag_cse((x+y)^2 + (x+y))
    @test length(dag2.labels) == 6
end
