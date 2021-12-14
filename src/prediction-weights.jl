DEFAULT_PRW_PROPERTIES = Dict(
    :activation => 0,
    :age => 1,
    :value => 1,
    :weight => :prw,
    :p => 1
)

neurons(g) = [v for v in vertices(g) if !removed(v, g)]

"""
Creates or modifies a PrW between v1 and v2

Returns:
    true if a new PrW was created, false if a PrW was not created

    Note: Can return false even when PrW is updated
"""
function add_prw!(prw::MetaDiGraph, v1::Int, v2::Int)::Bool
    if !removed(v1, prw) && !removed(v2, prw) && !has_edge(prw, v1, v2)
        add_edge!(prw, v1, v2)
        set_props!(prw, v1, v2, copy(DEFAULT_PRW_PROPERTIES))
        return true
        # deal with this later
        # elseif get_prop(prw, v1, :age) < M # M=20 from paper
    end
    return false
end

function update_prw!(prw::MetaDiGraph, v1::Int, v2::Int)::Bool
    if removed(v1, prw) || removed(v2, prw) || !has_edge(prw, v1, v2) return false end
    if get_prop(prw, v1, v2, :activation) == 1 && get_prop(prw, v2, :activation) == 1
        update_prop!(prw, v1, v2, :value, x->x+1)
    end

    p = get_prop(prw, v1, v2, :value) / get_prop(prw, v1, v2, :age)
    set_prop!(prw, v1, v2, :p, p)
    if get_prop(prw, v1, :activation) == 1

        update_prop!(prw, v1, v2, :age, x->x+1)
    end

    if p > 1
        error("Error:", get_prop(prw, v1, v2, :value), ">", get_prop(prw, v1, v2, :age))
    end

    return true
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
function PrW(prw::MetaDiGraph, v1::Int, v2::Int; one_decimal::Bool=false)
    if has_edge(prw, v1, v2)
        if get_prop(prw, v1, v2, :value) > get_prop(prw, v1, v2, :age)
            error("Error:", get_prop(prw, v1, v2, :value), ">", get_prop(prw, v1, v2, :age))
        end
        p = get_prop(prw, v1, v2, :p)
        one_decimal && return round(p, digits=1)
        return p
    end
    return 0
end

PrW(prw::MetaDiGraph, edge; one_decimal::Bool=false) = PrW(prw, edge.src, edge.dst;one_decimal=one_decimal)

function is_similar(prw::MetaDiGraph, v1::Int, v2::Int)
    if outneighbors(prw, v1) != outneighbors(prw, v2)
        return false
    end
    for neighbor in outneighbors(prw, v1)
        if PrW(prw, v1, neighbor; one_decimal=true) != PrW(prw, v2, neighbor; one_decimal=true)
            return false
        end
    end
    return true
end

function activate_PrW!(en::EpsilonNetwork)
    for prw in edges(en.prw)
        update_prw!(en.prw, prw.src, prw.dst)
        if get_prop(en.prw, prw, :activation) == 1
            set_prop!(en, prw, :activation, 0)
        end
    end
end
