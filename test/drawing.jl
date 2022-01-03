@testset "draw_pdf" begin
    data = [1 5 6 7 8 9 10 11 12; 2 4 5 6 7 9 10 11 12; 3 4 5 6 7 8 9 10 11]
    data = cat([data for i in 1:50]..., dims=1)
    num_inputs = length(unique(data))
    en = EpsilonNetwork(num_inputs)

    for i in 1:size(data, 1)
        process_input!(en, data[i, :])
    end

    draw_en("/tmp/test.pdf", en; hide_small_predictions=true)
    rm("/tmp/test.pdf")
    @test true # Just run this and see if it errors
end
