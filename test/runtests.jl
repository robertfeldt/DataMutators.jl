include("helper.jl")

@testset "DataShrinkers test suite" begin
    include("test_array_shrinker.jl")
    include("test_number_shrinker.jl")
    include("test_shrink_methods.jl")
end