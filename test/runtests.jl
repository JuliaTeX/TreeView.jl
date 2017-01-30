using TreeView
using Base.Test

# write your own tests here
@testset "@tree" begin

    t = @tree 1x

    @test typeof(t) == TreeView.LabelledTree
    @test typeof(t.g) == LightGraphs.DiGraph
    @test typeof(t.labels) == Vector{Any}

    @test t.g.vertices == 1:3
    @test t.labels == Any[:*,1,:x]


    t = @tree x^2 + y^2
    @test length(t.labels) == 7
end

@testset "latex special characters" begin
    # Test for issues with the characters present in julia's generated symbols
    expr = Expr(Symbol("##271"))
    t = walk_tree(expr)
    @test t.labels[1] == Symbol("##271")
end

@testset "DAG" begin
    dag = @dag x + 2x
    @test length(dag.labels) == 4
end
