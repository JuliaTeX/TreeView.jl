using TreeView
using Base.Test

# write your own tests here
@testset "@tree" begin

    t = @tree 1x

    @test typeof(t) == TreeView.LabelledTree
    @test typeof(t.g) == LightGraphs.Graph
    @test typeof(t.labels) == Vector{String}

    @test t.g.vertices == 1:3
    @test t.labels == String["\\texttt{*}","\\texttt{1}","\\texttt{x}"]


    t = @tree x^2 + y^2
    @test length(t.labels) == 7
end
