module TreeView

using LightGraphs, TikzGraphs
using MacroTools

export LabelledTree, walk_tree, walk_tree!, draw, @tree, @tree_with_call,
        tikz_representation

include("dag.jl")
export make_dag


immutable LabelledTree
    g::Graph
    labels::Vector{String}
end

add_numbered_vertex!(g) = (add_vertex!(g); top = nv(g))  # returns the number of the new vertex

# latex treats # as a special character, so we have to escape it. See:
# https://github.com/sisl/TikzGraphs.jl/issues/12
latex_escape(s::String) = replace(s, "#", "\\#")

"Convert the current node into a label"
function label(sym)
    sym == :(^) && return "\\textasciicircum"  # TikzGraphs chokes on ^

    return latex_escape(string("\\texttt{", sym, "}"))
end


"""
    walk_tree!(g, labels, ex, show_call=true)

Walk the abstract syntax tree (AST) of the given expression `ex`.
Builds up the graph `g` and the set of `labels`
for each node, both modified in place

`show_call` specifies whether to include `call` nodes in the graph.
Including them represents the Julia AST more precisely, but adds visual noise.

Returns the number of the top vertex.
"""

function walk_tree!(g, labels, ex, show_call=true)

    top_vertex = add_numbered_vertex!(g)

    where_start = 1  # which argument to start with

    if !(show_call) && ex.head == :call
        f = ex.args[1]   # the function name
        push!(labels, label(f))

        where_start = 2   # drop "call" from tree

    else
        push!(labels, label(ex.head))
    end


    for i in where_start:length(ex.args)

        if isa(ex.args[i], Expr)

            child = walk_tree!(g, labels, ex.args[i], show_call)
            add_edge!(g, top_vertex, child)

        else
            n = add_numbered_vertex!(g)
            add_edge!(g, top_vertex, n)

            push!(labels, label(ex.args[i]))

        end
    end

    return top_vertex

end

function walk_tree(ex::Expr, show_call=false)
    g = Graph()
    labels = String[]

    walk_tree!(g, labels, ex, show_call)

    return LabelledTree(g, labels)

end

tikz_representation(tree) = TikzGraphs.plot(tree.g, tree.labels)

import Base.show
function show(io::IO, mime::MIME"image/svg+xml", tree::LabelledTree)
    p = tikz_representation(tree)  # TikzPicture object
    show(io, mime, p)
end



function draw(tree::LabelledTree)
    TikzGraphs.plot(tree.g, tree.labels)
end


macro tree(ex::Expr)
    walk_tree(ex)
end

macro tree_with_call(ex::Expr)
    walk_tree(ex, true)
end


end # module
