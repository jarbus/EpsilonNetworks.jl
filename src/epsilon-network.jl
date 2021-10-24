# Specify functions you want to extend with multidispatch
#
using Graphs, MetaGraphs, GraphPlot
import MetaGraphs: AbstractMetaGraph, PropDict, MetaDict, set_prop!, get_prop, props, rem_vertex!, add_vertex!, merge_vertices!, add_edge!, nv

# For drawing en
using Compose
import Cairo, Fontconfig

using Test


# Verticies in all graphs share same properties
# This must be defined before importing any graphs
# Individual graphs have their own edge properties
DEFAULT_VERTEX_PROPERTIES = Dict(
    :name => "0",
    :original_numbers => Set(0),
    :activation => 0,
    :age => 0,
    :value => 0,
    :removed => false,
)

M = 40

mutable struct EpsilonNetwork
    prw::MetaDiGraph
    paw::MetaDiGraph
    stm::Set{Int}
    removed_neurons::Set{Int}
    snap_map::Dict{Int, Int}
    time_step::Int
end


function EpsilonNetwork(x::Int)
    snap_map = Dict(i => i for i in 1:x)
    en = EpsilonNetwork(
        MetaDiGraph(), # prw
        MetaDiGraph(), # paw
        Set(),         # removed neurons
        Set(),         # stm
        snap_map,      # snap_map
        1,             # timestep
    )
    for i in 1:x
        add_neuron!(en)
    end
    return en
end


include("./prediction-weights.jl")
include("./pattern-weights.jl")


# iterable of all metadigraphs in epsilon network
networks(en::EpsilonNetwork) = (en.prw, en.paw)
is_directed(en::EpsilonNetwork) = true
# nodes in all graphs are identical, so we just get the props of node v in the first graph
props(en::EpsilonNetwork, v::Int) = props(networks(en)[1], v)
get_prop(en::EpsilonNetwork, v::Int, prop::Symbol) = get_prop(networks(en)[1], v, prop)
neurons(en::EpsilonNetwork) = [v for v in vertices(networks(en)[1]) if !removed(v, en)]
nv(en::EpsilonNetwork) = nv(networks(en)[1])
is_active(en::EpsilonNetwork, v::Int) = Bool(get_prop(networks(en)[1], v, :activation))
deactivate_neuron!(en::EpsilonNetwork, v::Int) = set_prop!(en, v, :activation, 0)
valid_edges(mg::MetaDiGraph) = [e for e in edges(mg) if !removed(e.src, en) && !removed(e.dst, en)]
removed(v::Int, en::EpsilonNetwork) = in(v, en.removed_neurons)

function update_prop!(en::EpsilonNetwork, v::Int, prop::Symbol, func::Function)
    for weight_graph in networks(en)
        set_prop!(weight_graph, v, prop, func(get_prop(weight_graph, v, prop)))
    end
end


function update_prop!(mg::AbstractMetaGraph, v1::Int, v2::Int, prop::Symbol, func::Function)
    set_prop!(mg, v1, v2, prop, func(get_prop(mg, v1, v2, prop)))
end


function add_neuron!(en::EpsilonNetwork)
    for weight_graph in networks(en)
        add_vertex!(weight_graph, copy(DEFAULT_VERTEX_PROPERTIES))
        set_prop!(weight_graph, nv(en), :name, string(nv(en)))
        set_prop!(weight_graph, nv(en), :original_numbers, Set(nv(en)))
    end
    return nv(networks(en)[1])
end



function process_input!(en::EpsilonNetwork, input_vector::Vector{Int})
    for input in input_vector
        neuron = en.snap_map[input]
        if !is_active(en, neuron)
            activate_neuron!(en, neuron)
            new_prws::Int = 0
            for prev_neuron in en.stm
                new_prws += add_prw!(en.prw, prev_neuron, neuron)
            end
            # Create pattern weight
            if new_prws == 0 && length(en.stm) > 1 && max([PrW(en.prw, innei, neuron) for innei in inneighbors(en.prw, neuron)]...) < 0.8
                new_pattern_node = add_neuron!(en)
                create_pattern_weight(en, inneighbors(en.prw, neuron), new_pattern_node)
            end

        end
    end
    empty!(en.stm)
    for neuron in neurons(en)
        if is_active(en, neuron)
            push!(en.stm, neuron)
            deactivate_neuron!(en, neuron)
        end
    end
    if en.time_step % 50 == 0
        merge!(en.snap_map, snap!(en))
    end
    en.time_step += 1
end


# Functions to act on all graphs in the epsilon network
function activate_neuron!(en::EpsilonNetwork, v::Int)
    set_prop!(en, v, :activation, 1)
    if get_prop(en, v, :age) < M # M=20 from paper
        update_prop!(en, v, :age, x->x+1)
    end
end


function remove_neuron!(en::EpsilonNetwork, v::Int)
    for weight_graph in networks(en)
        for neighbor in inneighbors(weight_graph, v)
            rem_edge!(weight_graph, neighbor, v)
        end
        for neighbor in outneighbors(weight_graph, v)
            rem_edge!(weight_graph, v, neighbor)
        end
        set_prop!(weight_graph, v, :removed, true)
        push!(en.removed_neurons, v)
    end
end


function set_prop!(en::EpsilonNetwork, args...)
    for weight_graph in networks(en)
        set_prop!(weight_graph, args...)
    end
end

# Helper functions used in create_merged_vertex
rename_neuron!(en::EpsilonNetwork, v::Int, name::String) = set_prop!(en, v, :name, name)
mean(x::Vector) = sum(x)/length(x)
average_prop(prop_dicts::Vector{Dict{Symbol, Any}}, prop::Symbol)::Int = mean([d[prop] for d in prop_dicts]) |> x -> round(Int, x)


function create_merged_vertex!(en::EpsilonNetwork, vs::Vector{Int})
    # Make a new neuron with the average props of vs
    neuron = add_neuron!(en)
    set_prop!(en, neuron, :age, average_prop([props(en, v) for v in vs], :age))
    set_prop!(en, neuron, :value, average_prop([props(en, v) for v in vs], :value))
    og_numbers::Vector{Int} = [n for n in union([get_prop(en, v, :original_numbers) for v in vs]...)]
    set_prop!(en, neuron, :original_numbers, Set(og_numbers))
    name = string("{",[string(v, ", ") for v in og_numbers[1:end-1]]...,string(og_numbers[end]),"}")
    rename_neuron!(en, neuron, name)
    for weight_graph in networks(en)
        all_out_neighbors::Set{Int} = [outneighbors(weight_graph, v) for v in vs] |> x->cat(x..., dims=1) |> Set
        all_in_neighbors::Set{Int}  = [inneighbors(weight_graph, v) for v in vs] |> x->cat(x..., dims=1) |> Set
        for out_neighbor in all_out_neighbors
            # merge all props that go from one node into to multiple nodes in vs
            #
            #  vs[1]
            #       \
            #        V                         new_edge
            #        u    =======>  new neuron ---------> u
            #        ^
            #       /
            #  vs[2]
            #
            current_edges = [
                    props(weight_graph, v, out_neighbor)
                    for v in vs if has_edge(weight_graph, v, out_neighbor)
            ]

            new_edge_props = copy(DEFAULT_PRW_PROPERTIES)
            new_edge_props[:age] = average_prop(current_edges, :age)
            new_edge_props[:value] = average_prop(current_edges, :value)
            add_edge!(weight_graph, neuron, out_neighbor, new_edge_props)
        end
        for in_neighbor in all_in_neighbors

            # merge all props that go from one node into to multiple nodes in vs
            #
            #    vs[1]
            #     ^
            #    /                     new_edge
            #  u          =======>  u ----------> new neuron
            #    \
            #     V
            #     vs[2]
            #
            current_edges = [
                props(weight_graph, in_neighbor, v)
                for v in vs if has_edge(weight_graph, in_neighbor, v)
            ]

            new_edge_props = copy(DEFAULT_PRW_PROPERTIES)
            new_edge_props[:age] = average_prop(current_edges, :age)
            new_edge_props[:value] = average_prop(current_edges, :value)

            add_edge!(weight_graph, in_neighbor, neuron, new_edge_props)
        end
    end
    return neuron
end


function snap!(en::EpsilonNetwork)
    similar_neurons = Vector{Vector{Int}}()
    snap_map::Dict{Int,Int} = Dict()
    for neuron in neurons(en)
        found_snap_group = false
        for (j, neuron_group) in enumerate(similar_neurons)
            if is_similar(en.prw, neuron, neuron_group[1])
                push!(similar_neurons[j], neuron)
                found_snap_group = true
                break
            end
        end
        if !found_snap_group
            push!(similar_neurons, [neuron])
        end
    end
    for snap_set in similar_neurons
        if length(snap_set) > 1
            new_neuron::Int = create_merged_vertex!(en, snap_set)
            for original_number in get_prop(en, new_neuron, :original_numbers)
                snap_map[original_number] = new_neuron
            end
            snap_map[new_neuron] = new_neuron
            for neuron in snap_set
                remove_neuron!(en, neuron)
            end
        else
            for neuron in snap_set
                if !get_prop(en, neuron, :removed)
                    snap_map[neuron] = neuron
                end
            end
        end
    end

    return snap_map
end

function draw_en(en::EpsilonNetwork)
    # Remove PrW with small probabilities
    rem_small_prw!(en.prw)
    # Draw all nodes in en
    nodelabels = [get_prop(en, n, :name) for n in neurons(en)]

    edgelabels = [PrW(en.prw, edge) for edge in valid_edges(en.prw)]
    subgraph = induced_subgraph(en.prw, [n for n in neurons(en) if !get_prop(en.prw, n, :removed)])[1]
    draw(PDF("prw.pdf", 16cm, 16cm), gplot(subgraph, layout=circular_layout, nodelabel=nodelabels, edgelabel=edgelabels))

end
