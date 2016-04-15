if VERSION >= v"0.5-"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

using DataShrinkers
using GodelTest

include("test_array_shrinker.jl")