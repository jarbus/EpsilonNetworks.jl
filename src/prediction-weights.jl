DEFAULT_PRW_PROPERTIES = Dict(
    :activation => 0,
    :age => 1,
    :value => 1,
)

removed(v, prw::MetaDiGraph) = get_prop(prw, v, :removed)
neurons(g) = [v for v in vertices(g) if !removed(v, g)]

"""
Creates or modifies a PrW between v1 and v2

Returns:
    true if a new PrW was created, false if a PrW was not created

    Note: Can return false even when PrW is updated
"""
function add_prw!(prw::MetaDiGraph, v1::Int, v2::Int)::Bool
    if !get_prop(prw, v1, :removed) && !get_prop(prw, v2, :removed)
        if !has_edge(prw, v1, v2)
            add_edge!(prw, v1, v2)
            set_props!(prw, v1, v2, DEFAULT_PRW_PROPERTIES)
            return true
        elseif get_prop(prw, v1, :age) < M # M=20 from paper
            set_prop!(prw, v1, v2, :value, get_prop(prw, v1, v2, :value)+1)
        end
    end
    return false
end

function rem_small_prw!(prw::MetaDiGraph)
    for edge in valid_edges(prw)
        if PrW(prw, edge) < 0.8
            success::Bool = rem_edge!(prw, edge)
            if !success
                println("failed to remove edge")
            end
        end
    end
end


"""
    Returns prediction weight probability between v1 and v2 if it exists,
returns 0 otherwise
"""
function PrW(prw::MetaDiGraph, v1::Int, v2::Int)
    if has_edge(prw, v1, v2)
        return round(get_prop(prw, v1, v2, :value) /
              get_prop(prw, v1, :age), digits=1)
    end
    return 0
end

function PrW(prw::MetaDiGraph, edge)
    round(get_prop(prw, edge.src, edge.dst, :value) /
          get_prop(prw, edge.src, :age), digits=1)
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
