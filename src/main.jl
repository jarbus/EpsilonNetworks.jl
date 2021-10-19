using Revise
using LightGraphs, MetaGraphs, GraphPlot
using Compose
import Cairo, Fontconfig
include("./epsilon-network.jl")

# Falling ball example
# Black is 1 2 3, White is 4 5 6
# data = [1 5 6; 2 4 6; 3 4 7]
# data = [1 5 3; 2 4 3]
# data = [1; 1]
# data = [1 4; 2 3; 1 4; 2 3; 1 4]
#
#   B         W
# 1         4  5  6
#   2       7  8  9
#     3    10 11 12
#
#
data = [1 5 6 7 8 9 10 11 12; 2 4 5 6 7 9 10 11 12; 3 4 5 6 7 8 9 10 11]
data = cat([data for i in 1:50]..., dims=1)
num_inputs = length(unique(data))
snap_map = Dict(i => i for i in 1:num_inputs)
en = EpsilonNetwork(num_inputs)
stm = Set()

# print(snap_map)
for i in 1:size(data, 1)
    for input in data[i,:]
        neuron = snap_map[input]
        if !is_active(en, neuron)
            activate_neuron!(en, neuron)
            for prev_neuron in stm
                add_prw!(en.prw, prev_neuron, neuron)
            end
        end
    end
    empty!(stm)
    for neuron in neurons(en)
        if is_active(en, neuron)
            push!(stm, neuron)
            deactivate_neuron!(en, neuron)
        end
    end
    if i % 50 == 0
        merge!(snap_map, snap!(en.prw))
        # println(snap_map)
    end
end

draw_en(en)

# edgelabels =
#     [  (edge.src, edge.dst, PrW(en.prw, edge.src, edge.dst), get_prop(en.prw, edge.src, edge.dst, :value))
#     for edge in edges(en.prw)
# ]
# for n in neurons(en)
#     println(get_prop(en, n, :original_numbers))
# end
