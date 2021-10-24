include("../src/epsilon-network.jl")
using Test

@testset "EpsilonNetworks" begin
    en = EpsilonNetwork(1)
    @test neurons(en) == [1]
    add_neuron!(en)
    @test neurons(en) == [1, 2]
end
