
# latex treats # as a special character, so we have to escape it. See:
# https://github.com/sisl/TikzGraphs.jl/issues/12

# latex_escape(s::String) = replace(s, Dict("#"=>"\\#", "&"=>"\\&"))

function latex_escape(s::String)
    s = replace(s, "#"=>"\\#")
    s = replace(s, "&"=>"\\&")
    return s
end

"Convert a symbol or  into a LaTeX label"
function latex_label(sym)
    sym == :(^) && return "\\textasciicircum"  # TikzGraphs chokes on ^

    return latex_escape(string("\\texttt{", sym, "}"))
end


"""
Return a Tikz representation of a tree object.
The tree object must have fields `g` (the graph) and `labels`.
"""
function tikz_representation(tree::LabelledDiGraph)
    labels = String[latex_label(x) for x in tree.labels]
    return TikzGraphs.plot(tree.g, labels)
end


function Base.show(io::IO, mime::MIME"image/svg+xml", tree::LabelledTree)

    p = tikz_representation(tree)  # TikzPicture object
    show(io, mime, p)

end
