@testset "EpsilonNetworks" begin
    en = EpsilonNetwork(1)
    @test EpsilonNetworks.neurons(en) == [1]
    EpsilonNetworks.add_neuron!(en)
    @test EpsilonNetworks.neurons(en) == [1, 2]
end
