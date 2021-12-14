using EpsilonNetworks
using Graphs, MetaGraphs
using Test


# This gets rid of debug statements during testing
ENV["JULIA_DEBUG"] = Main

# include("epsilon-network.jl")
include("test-prediction-weights.jl")
include("epsilon-network.jl")
