@testset "basics" begin
    en = EpsilonNetwork(1)
    @test EpsilonNetworks.neurons(en) == [1]
    EpsilonNetworks.add_neuron!(en)
    @test EpsilonNetworks.neurons(en) == [1, 2]
    EpsilonNetworks.activate_neuron!(en, 1)
    @test 1 ∈ EpsilonNetworks.active_neurons(en)
    @test 2 ∉ EpsilonNetworks.active_neurons(en)
    EpsilonNetworks.deactivate_neuron!(en, 1)
    @test 1 ∉ EpsilonNetworks.active_neurons(en)
    @test 2 ∉ EpsilonNetworks.active_neurons(en)
end
