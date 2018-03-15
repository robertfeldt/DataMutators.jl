module DataMutators

using DataGenerators
using StatsBase
using Compat

export shrink, mutate, grow

# Utils
include("type_chain_iterators.jl")

# Types
include("abstract_mutations.jl")
include("abstract_data_mutator.jl")

# Library
include("shrinker_library.jl")

# Top-level API
include("shrink_methods.jl")
include("size_reduction_analysis.jl")

# Shrinkers and Mutators
include("array_shrinkers.jl")
include("number_shrinkers.jl")
include("string_mutators.jl")

# Type switching mutators
#include("type_switching_mutator.jl")

end