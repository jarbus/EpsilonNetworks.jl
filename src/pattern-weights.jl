# Pattern weights are for combining PrW that each have too low a probability
DEFAULT_PAW_PROPERTIES = Dict(
    :activation => 0,
    :age => 1,
    :value => 1,
    :weight => :paw
)

"""
    Create pattern weight C that takes as input as and predicts b
    Returns 0 if pattern weight already exists, returns 1 if a new PaW is made
"""
function create_pattern_weight(en::EpsilonNetwork, as::Vector{Int}, b::Int)
    @debug "Created pattern weight" as b
    if [has_edge(en.paw, a, b) for a in as] |> all return 0 end
    if [length(inneighbors(en.paw, a)) > 0 for a in as] |> any return 0 end
    pattern_neuron::Int = add_neuron!(en)
    for a in as
        add_edge!(en.paw, a, pattern_neuron)
        set_props!(en.paw, a, pattern_neuron, copy(DEFAULT_PAW_PROPERTIES))
    end
    add_prw!(en.prw, pattern_neuron, b)
    return 1
end


# Algorithm 3 from the paper
function update_pattern_weights(en::EpsilonNetwork, b::Int)
    @debug "Updated Pattern Weight"
    # strong_neighbors is list of neurons that predict b and have pattern weights
    strong_neighbors = [a for a in inneighbors(en.prw, b) if PrW(en.prw, a, b) > 0.9]
    strong_neighbors = filter(a->length(inneighbors(en.paw, a)) > 0, strong_neighbors)
    for predictive_neighbor in strong_neighbors
        # Update PaW
        for n in inneighbors(en.paw, predictive_neighbor)
            update_prop!(en.paw, n, predictive_neighbor, :age, x->x+1)
            if n ∈ en.stm
                update_prop!(en.paw, n, predictive_neighbor, :value, x->x+1)
            end
        end

    end
end

function activate_PaW!(en::EpsilonNetwork)
    pattern_activation = true
    # Unactivated Pattern nodes set is just the set of all pattern edge destinations
    unactivated::Set{Int} = map(x->x.dst, edges(en.paw)) |> Set
    while pattern_activation && !isempty(unactivated)
        pattern_activation = false
        for pattern_neuron in unactivated
            A = zeros(10)
            S = zeros(10)
            for pattern_src in inneighbors(en.paw, pattern_neuron)
                # [0, 1)::Float64 |> [0, 10]::Int
                idx = w(en, pattern_src, pattern_neuron) * 10 |> floor |> Int
                if idx == 0 continue end
                if is_active(en, pattern_src)
                    A[idx] += 1
                end
                S[idx] += 1
            end

            # ensure the denominator of the PaW activation
            # is at least 1
            S = map(x-> x==0 ? 1 : x, S)
            # Compute percentage of active for each prob interval
            probability_ratio = map(x-> isnan(x) ? 1.0 : x, A ./ S)
            if all(probability_ratio .> 0:0.1:0.9)
                activate_neuron!(en, pattern_neuron)
                pop!(unactivated, pattern_neuron)
                pattern_activation = true
            end
        end
    end
end




function w(en::EpsilonNetwork, src::Int, dst::Int)
    get_prop(en.paw, src, dst, :value) / max(get_prop(en.paw, src, dst, :age), 1)
end
