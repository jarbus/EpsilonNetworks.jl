@testset "prws" begin
    en = EpsilonNetwork(2)

    process_input!(en, [1])
    @test ne(en.prw) == 0

    process_input!(en, [2])
    @test EpsilonNetworks.PrW(en.prw, 1, 2) == 1.0
    @test ne(en.prw) == 1

    process_input!(en, [1])
    @test ne(en.prw) == 2
    @test EpsilonNetworks.PrW(en.prw, 2, 1) == 1.0
    @test EpsilonNetworks.PrW(en.prw, 1, 2) == 0.5
    @test EpsilonNetworks.neurons(en) == [1, 2]

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

@testset "snap" begin

    en = EpsilonNetwork(4)

    for _ in 1:4
        process_input!(en, [1, 2, 3])
        process_input!(en, [4])
    EpsilonNetworks.snap(en)
    @test ne(en.prw) == 1
    @test length(neurons(en.prw)) == 2
end
