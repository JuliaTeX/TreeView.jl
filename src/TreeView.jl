module TreeView

using LightGraphs, TikzGraphs
using MacroTools
using CommonSubexpressions

export LabelledTree, walk_tree, walk_tree!, draw, @tree, @tree_with_call,
        tikz_representation

export make_dag, @dag, @dag_cse


abstract type LabelledDiGraph
end

struct LabelledTree <: LabelledDiGraph
    g::DiGraph
    labels::Vector{Any}
end

add_numbered_vertex!(g) = (add_vertex!(g); top = nv(g))  # returns the number of the new vertex

include("tree.jl")
include("dag.jl")
include("display.jl")

end # module
