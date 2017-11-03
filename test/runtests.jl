include("helper.jl")

@testset "DataMutators test suite" begin
    include("test_array_shrinker.jl")
    include("test_number_shrinker.jl")
    include("test_shrink_methods.jl")
    include("test_type_switching_mutator.jl")
end