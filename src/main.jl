using LightGraphs, MetaGraphs
include("./prediction-network.jl")

input_size = (3, 2)
neuron_count = reduce(*, input_size)

prw = PredictionWeights(neuron_count)
println(typeof(prw))
println(nv(prw))


