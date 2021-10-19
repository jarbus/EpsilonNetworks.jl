DEFAULT_EDGE_PROPERTIES = Dict(
    :activation => 0,
    :age => 1,
    :value => 1,
)

removed(v, prw::MetaDiGraph) = get_prop(prw, v, :removed)
neurons(g) = [v for v in vertices(g) if !removed(v, g)]

function add_prw!(prw::MetaDiGraph, v1::Int, v2::Int)
    if !get_prop(prw, v1, :removed) && !get_prop(prw, v2, :removed)
        if !has_edge(prw, v1, v2)
            add_edge!(prw, v1, v2)
            set_props!(prw, v1, v2, DEFAULT_EDGE_PROPERTIES)
        else
            set_prop!(prw, v1, v2, :value, get_prop(prw, v1, v2, :value)+1)
        end
    end
end


function PrW(prw::MetaDiGraph, v1::Int, v2::Int)
    # println(get_prop(prw, v1, v2, :value), ", ", get_prop(prw, v1, :age), ": ",v1," => ",v2)
    round(get_prop(prw, v1, v2, :value) /
          get_prop(prw, v1, :age), digits=1)
end

function is_similar(prw::MetaDiGraph, v1::Int, v2::Int)
    if outneighbors(prw, v1) != outneighbors(prw, v2)
        return false
    end
    for neighbor in outneighbors(prw, v1)
        if PrW(prw, v1, neighbor) != PrW(prw, v2, neighbor)
            return false
        end
    end
    return true
end
