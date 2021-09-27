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
data = [1 4; 2 3; 1 4; 2 3; 1 4]

en = EpsilonNetwork(length(unique(data)))
stm = Set()

for i in 1:size(data, 1)
    for neuron in data[i,:]
        activate_neuron!(en, neuron)
        for prev_neuron in stm
            add_prw!(en.prw, prev_neuron, neuron)
        end
    end
    empty!(stm)
    for neuron in neurons(en)
        if is_active(en, neuron)
            push!(stm, neuron)
            deactivate_neuron!(en, neuron)
        end
    end
end


snap!(en.prw)
draw_prw(en)

edgelabels =
    [  (edge.src, edge.dst, PrW(en.prw, edge.src, edge.dst), get_prop(en.prw.graph, edge.src, edge.dst, :value))
    for edge in edges(en.prw.graph)
        if !in(edge.src, en.removed_neurons) && !in(edge.dst, en.removed_neurons)
]
