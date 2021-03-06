include("helper.jl")

@testset "DataMutators test suite" begin
    include("test_type_chain_iterators.jl")

    include("test_array_mutators.jl")
    include("test_number_mutators.jl")

    include("test_shrink_methods.jl")

    #include("test_type_switching_mutator.jl")

    include("test_string_mutators.jl")

    include("test_readme_examples.jl")
end