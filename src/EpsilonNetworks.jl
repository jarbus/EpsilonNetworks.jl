module EpsilonNetworks

using Graphs
using Graphs.SimpleGraphs
using MetaGraphs
import MetaGraphs: MetaDiGraph, add_vertex!, nv, vertices, set_prop!, get_prop, props, rem_vertex!, add_vertex!, merge_vertices!, add_edge!, has_edge, inneighbors, outneighbors, rem_edge!, edges, induced_subgraph

using GraphPlot
# For drawing en
using Compose
import Cairo, Fontconfig

include("./epsilon-network.jl")
export
    EpsilonNetwork,
    process_input!,
    draw_en

end
