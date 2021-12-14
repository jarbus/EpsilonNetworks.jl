# Pattern weights are for combining PrW that each have too low a probability
DEFAULT_PAW_PROPERTIES = Dict(
    :activation => 0,
    :age => 1,
    :value => 1,
    :weight => :paw
)

"""
    Create pattern weight C that takes as input as and predicts b
"""
function create_pattern_weight(en::EpsilonNetwork, as::Vector{Int}, b::Int)
    pattern_neuron::Int = add_neuron!(en)
    for a in as
        add_edge!(en.paw, a, pattern_neuron)
        set_props!(en.paw, a, pattern_neuron, copy(DEFAULT_PAW_PROPERTIES))
    end
    add_prw!(en.prw, pattern_neuron, b)
    set_prop!(en, pattern_neuron, :age, 1)

end

function w(en::EpsilonNetwork, neuron::Int)
    get_prop(en.paw, neuron, :value) / max(get_prop(en.paw, neuron, :age), 1)
end
