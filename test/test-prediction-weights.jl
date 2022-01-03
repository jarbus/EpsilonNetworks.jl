@testset verbose = true "prws" begin
    @testset "basics" begin
        en = EpsilonNetwork(2)

        process_input!(en, [1])
        @test ne(en.prw) == 0

        process_input!(en, [2])
        @test EpsilonNetworks.PrW(en.prw, 1, 2) == 1.0
        @test ne(en.prw) == 1

        process_input!(en, [1])
        @test ne(en.prw) == 2
        @test EpsilonNetworks.PrW(en.prw, 2, 1) == 1.0
        @test EpsilonNetworks.PrW(en.prw, 1, 2) == 1.0
        @test EpsilonNetworks.neurons(en) == [1, 2]

        process_input!(en, [2])
        process_input!(en, [1])
        process_input!(en, [2])
        process_input!(en, [1])
        process_input!(en, [2])
        process_input!(en, [1])
        process_input!(en, [2])
        process_input!(en, [1])

        @test 2 ∈ en.predicted # takes a while to reach 80% confidence
        @test ne(en.prw) == 2
        @test EpsilonNetworks.PrW(en.prw, 2, 1) == 1.0
    end

    @testset "check prw decrease" begin
        en = EpsilonNetwork(3)

        process_input!(en, [1])
        process_input!(en, [2])
        @test EpsilonNetworks.PrW(en.prw, 1, 2) == 1.0
        process_input!(en, [1])
        @test EpsilonNetworks.PrW(en.prw, 1, 2) == 1.0
        process_input!(en, [3])
        @test EpsilonNetworks.PrW(en.prw, 1, 2) == 0.5


    end

    @testset "snap" begin
        en = EpsilonNetwork(4)

        process_input!(en, [1, 2, 3])
        process_input!(en, [4])
        EpsilonNetworks.snap!(en)
        process_input!(en, [1, 2, 3])
        process_input!(en, [4])
        @test ne(en.prw) == 2
        @test length(EpsilonNetworks.neurons(en.prw)) == 2
        @test EpsilonNetworks.PrW(en.prw, 4, 5) == 1.0
        @test EpsilonNetworks.PrW(en.prw,  5, 4) == 1.0
    end

    @testset "proper value/age values" begin
        # This test can yield value > age
        # for prw 2 => 3 if computation
        # is executed is out of order
        en = EpsilonNetwork(3)
        process_input!(en, [1, 2])
        process_input!(en, [2, 3])
        process_input!(en, [1, 3])
        @test EpsilonNetworks.PrW(en.prw, 2, 3) == 1.0
    end
end
