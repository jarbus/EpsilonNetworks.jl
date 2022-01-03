@testset verbose = true "paw" begin

    @testset "creation" begin
        en = EpsilonNetwork(4)
        process_input!(en, [3,2,1])
        process_input!(en, [4])
        EpsilonNetworks.set_prop!(en, 1, 4, :age, 10)
        EpsilonNetworks.set_prop!(en, 2, 4, :age, 10)
        EpsilonNetworks.set_prop!(en, 3, 4, :age, 10)
        process_input!(en, [3,2,1])
        process_input!(en, [4])

        @test ne(en.paw) == 3
        @test length(EpsilonNetworks.neurons(en)) == 5
        @test EpsilonNetworks.w(en, 1,5) == EpsilonNetworks.w(en, 2,5) == EpsilonNetworks.w(en, 3,5) == 1.0
        @test EpsilonNetworks.PrW(en.prw, 5, 4) == 1.0
    end

    @testset "creation + update" begin
        # Test updating PaW from 1.0 -> 0.5
        en = EpsilonNetwork(4)
        process_input!(en, [3,2,1])
        process_input!(en, [4])
        process_input!(en, Vector{Int}())
        EpsilonNetworks.set_prop!(en, 1, 4, :age, 10)
        EpsilonNetworks.set_prop!(en, 2, 4, :age, 10)
        EpsilonNetworks.set_prop!(en, 3, 4, :age, 10)
        process_input!(en, [3,2,1])
        process_input!(en, [4])
        process_input!(en, Vector{Int}())
        process_input!(en, [1,2])
        process_input!(en, [4])

        @test length(EpsilonNetworks.neurons(en)) == 5
        @test EpsilonNetworks.w(en, 1,5) == EpsilonNetworks.w(en, 2,5) == 1.0
        @test EpsilonNetworks.w(en, 3,5) == 0.5
        @test EpsilonNetworks.PrW(en.prw, 5, 4) == 1.0

    end
end
