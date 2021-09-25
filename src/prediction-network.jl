using LightGraphs, MetaGraphs

# Specify functions you want to extend, for some reason
import MetaGraphs: AbstractMetaGraph, PropDict, MetaDict

# Any function that works with a SimpleGraph gets forwarded from Prediction Weights
mutable struct PredictionWeights{T <: Integer,U <: Real} <: AbstractMetaGraph{T}
    graph::MetaGraph{T, U}
    # TODO forward all metagraph functions
end

# Initialize graph with x nodes and no edges
PredictionWeights(x::Int) = PredictionWeights(MetaGraph(x))
