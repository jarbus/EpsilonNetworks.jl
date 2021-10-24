# Pattern weights are for combining PrW that each have too low a probability

"""
    Create pattern weight C that takes as input as and predicts b
"""
function create_pattern_weight(en::EpsilonNetwork, as::Vector{Int}, b::Int)
    pattern_neuron::Int = add_neuron!(en)
    for a in as
        add_edge!(en.paw, v, pattern_neuron)
    end
    add_prw!(en.prw, pattern_neuron, b)
end
