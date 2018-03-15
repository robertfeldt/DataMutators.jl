abstract AbstractDataMutator
isshrinker(m::AbstractDataMutator) = false

# For Mutators that always shrinks
abstract AbstractDataShrinker <: AbstractDataMutator
isshrinker(m::AbstractDataShrinker) = true

# We might want to support more complex ways of selecting mutators from a set later
# so introduce types for it.
abstract AbstractMutatorSelectionContext

# Default selects a random mutator after having (optionally) filtered 
# out only the shrinkers.
immutable DefaultMutatorSelectionContext <: AbstractMutatorSelectionContext
    shrinkonly::Bool
end
DefaultMutatorSelectionContext() = DefaultMutatorSelectionContext(false)

filter_shrinkers(ms::Vector{AbstractDataMutator}) = 
    filter(m -> typeof(m) <: AbstractDataShrinker || isshrinker(m), ms)

import Base.filter
function filter(mc::DefaultMutatorSelectionContext, mutators::Vector{AbstractDataMutator})
    if mc.shrinkonly && length(mutators) > 0
        mutators = filter_shrinkers(mutators)
    end
    return mutators
end

function select(mc::DefaultMutatorSelectionContext, mutators::Vector{AbstractDataMutator})
    mutators = filter(mc, mutators)
    if length(mutators) > 0
        mutators[rand(1:length(mutators))]
    else
        return nothing
    end
end

mutate{T <: Any}(m::AbstractDataMutator, d::T; mutatorSelectionContext = DefaultMutatorSelectionContext()) = 
    apply(mutations(m, d; mutatorSelectionContext = mutatorSelectionContext), d)
mutate!{T <: Any}(m::AbstractDataMutator, d::T; mutatorSelectionContext = DefaultMutatorSelectionContext()) = 
    apply!(mutations(m, d; mutatorSelectionContext = mutatorSelectionContext), d)
mutations(m::AbstractDataMutator, d; mutatorSelectionContext = DefaultMutatorSelectionContext()) = 
    AbstractMutation[mutation(m, d; mutatorSelectionContext = mutatorSelectionContext)]

shrink{T <: Any}(m::AbstractDataShrinker, d::T) = mutate(m, d; mutatorSelectionContext = DefaultMutatorSelectionContext(false))
