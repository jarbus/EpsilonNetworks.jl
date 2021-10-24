include("../src/epsilon-network.jl")

# Falling ball example
# Black is 1 2 3, White is 4 5 6
# data = [1 5 6; 2 4 6; 3 4 7]
# data = [1 5 3; 2 4 3]
# data = [1; 1]
# data = [1 4; 2 3; 1 4; 2 3; 1 4]
#
#   B         W
# 1         4  5  6
#   2       7  8  9
#     3    10 11 12

# Bomb example
data = [1; 3; 5; 2; 4; 5]
data = cat([data for i in 1:50]..., dims=1)
num_inputs = length(unique(data))
en = EpsilonNetwork(num_inputs)

for i in 1:size(data, 1)
    process_input!(en, data[i, :])
end

draw_en(en)
