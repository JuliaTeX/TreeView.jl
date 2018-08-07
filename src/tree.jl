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
        push!(labels, f)

        where_start = 2   # drop "call" from tree

    else
        push!(labels, ex.head)
    end


    for i in where_start:length(ex.args)

        if isa(ex.args[i], Expr)

            child = walk_tree!(g, labels, ex.args[i], show_call)
            add_edge!(g, top_vertex, child)

        else
            n = add_numbered_vertex!(g)
            add_edge!(g, top_vertex, n)

            push!(labels, ex.args[i])

        end
    end

    return top_vertex

end

function walk_tree(ex::Expr, show_call=false)
    g = DiGraph()
    labels = Any[]

    walk_tree!(g, labels, ex, show_call)

    return LabelledTree(g, labels)

end

"""
Make a tree from a Julia `Expr`ession.
Omits `call`.
"""
macro tree(ex::Expr)
    walk_tree(ex)
end

"""
Make a tree from a Julia `Expr`ession.
Includes `call`.
"""
macro tree_with_call(ex::Expr)
    walk_tree(ex, true)
end
