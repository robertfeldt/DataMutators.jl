if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

using DataShrinkers
using GodelTest

@testset "DataShrinkers test suite" begin
    include("test_array_shrinker.jl")
    include("test_number_shrinker.jl")
end