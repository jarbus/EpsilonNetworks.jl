# TODO Add probabilities to edges, figure out how to get source age from an edge object
# Any function that works with a SimpleGraph gets forwarded from Pred Weights
mutable struct PredWeights{T <: Integer,U <: Real} <: AbstractWeightGraph{T}
    graph::MetaDiGraph{T, U}
end

DEFAULT_EDGE_PROPERTIES = Dict(
    :activation => 0,
    :age => 1,
    :value => 1,
)


# Initialize PredWeights graph with x neurons
PredWeights() = PredWeights(MetaDiGraph())


nv(prw::PredWeights) = nv(prw.graph)
props(prw::PredWeights, v::Int) = props(prw.graph, v)
neurons(prw::PredWeights) = vertices(prw.graph)

function add_prw!(prw::PredWeights, v1::Int, v2::Int)
    if !has_edge(prw.graph, v1, v2)
        add_edge!(prw.graph, v1, v2)
        set_props!(prw.graph, v1, v2, DEFAULT_EDGE_PROPERTIES)
    else
        set_prop!(prw.graph, v1, v2, :value, get_prop(prw.graph, v1, v2, :value)+1)
    end
end


function PrW(prw::PredWeights, v1::Int, v2::Int)
    return round(get_prop(prw.graph, v1, v2, :value) /
        get_prop(prw.graph, v1, :age), digits=1)

end

function is_similar(prw::PredWeights, v1::Int, v2::Int)
    if outneighbors(prw.graph, v1) != outneighbors(prw.graph, v2)
        return false
    end
    for neighbor in outneighbors(prw.graph, v1)
        if PrW(prw, v1, neighbor) != PrW(prw, v2, neighbor)
            return false
        end
    end
    return true
end
