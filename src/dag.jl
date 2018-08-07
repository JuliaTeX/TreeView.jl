# Make a DAG (Directed Acyclic Graph) by storing references to each symbol

"""
Structure representing a DAG.
Maintains a `symbol_map` giving the currently-known symbols and the corresponding
vertex number in the graph.
"""
struct DirectedAcyclicGraph <: LabelledDiGraph
    g::DiGraph
    labels::Vector{Any}
    symbol_map::Dict{Symbol, Int}
end

DirectedAcyclicGraph() = DirectedAcyclicGraph(DiGraph(), Symbol[], Dict())

"""
Adds a symbol to the DAG if it doesn't already exist.
Returns the vertex number
# Make numbers unique:
"""
function add_symbol!(dag::DirectedAcyclicGraph, s)  # number
    vertex = add_numbered_vertex!(dag.g)
    push!(dag.labels, s)
    return vertex
end

function lookup!(dag::DirectedAcyclicGraph, s)
    add_symbol!(dag, s)
end

"""
Look up a symbol to see if it has already been seen.
"""
function lookup!(dag::DirectedAcyclicGraph, s::Symbol)
    if haskey(dag.symbol_map, s)
        return dag.symbol_map[s]

    else  # make new one:
        vertex = add_numbered_vertex!(dag.g)
        push!(dag.labels, s)
        dag.symbol_map[s] = vertex
        return vertex
    end
end


make_dag!(dag::DirectedAcyclicGraph, s) = lookup!(dag, s)

"""
Update a Directed Acyclic Graph with the result of traversing the given `Expr`ession.
"""
function make_dag!(dag::DirectedAcyclicGraph, ex::Expr)

    local top

    if ex.head == :block
        for arg in ex.args
            make_dag!(dag, arg)
        end
        return -1

    elseif ex.head == :(=)  # treat assignment as just giving pointers to the tree
        local_var = ex.args[1]

        top = make_dag!(dag, ex.args[2])

        dag.symbol_map[local_var] = top  # add an alias to the corresponding tree node

        return top

    end


    where_start = 1  # which argument to start with

    if ex.head == :call
        f = ex.args[1]   # the function name
        top = add_symbol!(dag, f)

        where_start = 2   # drop "call" from tree


    else
        @show ex.head
        top = add_symbol!(dag, ex.head)
    end

    # @show top

    for arg in ex.args[where_start:end]

        # @show arg, typeof(arg)

        if isa(arg, Expr)

            child = make_dag!(dag, arg)
            # @show "Expr", top, child
            add_edge!(dag.g, top, child)

        else
            child = lookup!(dag, arg)
            # @show top, child
            add_edge!(dag.g, top, child)

        end
    end

    return top

end

"""
Make a Directed Acyclic Graph (DAG) from a Julia expression.
"""
function make_dag(ex::Expr)

    dag = DirectedAcyclicGraph()

    make_dag!(dag, MacroTools.striplines(ex))

    return dag

end

"""
Make a Directed Acyclic Graph (DAG) from a Julia expression.
"""
macro dag(ex::Expr)
    make_dag(ex)
end

"""
Perform common subexpression elimination on a Julia `Expr`ession,
and make a Directed Acyclic Graph (DAG) of the result.
"""
macro dag_cse(ex::Expr)
    make_dag(cse(ex))  # common subexpression elimination
end


import Base.show
function show(io::IO, mime::MIME"image/svg+xml", dag::DirectedAcyclicGraph)
    p = tikz_representation(dag)  # TikzPicture object
    show(io, mime, p)
end
