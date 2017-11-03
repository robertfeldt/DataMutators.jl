module DataMutators

using DataGenerators
using StatsBase

export shrink, mutate, grow

include("abstract_data_mutator.jl")

include("shrinker_library.jl")
include("shrink_methods.jl")

include("size_reduction_analysis.jl")

# Shrinkers
include("array_shrinkers.jl")
include("number_shrinkers.jl")

# Mutators
include("string_mutators.jl")

# Type changing mutators
include("type_switching_mutator.jl")

end