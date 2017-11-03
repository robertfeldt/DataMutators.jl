abstract AbstractDataMutator

mutate(m::AbstractDataMutator, d) = error("Not yet implemented!")
shrink(m::AbstractDataMutator, d) = mutate(m, d)
grow(m::AbstractDataMutator, d) = mutate(m, d)

abstract AbstractDataShrinker <: AbstractDataMutator

mutate(m::AbstractDataShrinker, d) = shrink(m, d)
grow(m::AbstractDataShrinker, d) = error("A shrinker cannot grow!")
