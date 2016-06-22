module DataMutators

using DataGenerators

export shrink

abstract AbstractDataShrinker

include("shrinker_library.jl")
include("shrink_methods.jl")

include("size_reduction_analysis.jl")

include("array_shrinkers.jl")
include("number_shrinkers.jl")

end