const LibTypeToMutators = Dict{Type, Vector{AbstractDataMutator}}()
const LibDescToMutators = Dict{AbstractString, AbstractDataMutator}()

shrinkers_for_type(t::Type) = filter(m -> typeof(m) <: AbstractDataShrinker, mutators_for_type(t))
mutators_for_type(t::Type) = get(LibTypeToMutators, t, AbstractDataMutator[])

function register{T <: Type}(m::AbstractDataMutator, t::T, desc = "")
    LibTypeToMutators[t] = mutators = mutators_for_type(t)
    push!(mutators, m)
    if haskey(LibDescToMutators, desc)
        if typeof(m) <: AbstractDataShrinker
            warn("Overwriting existing shrinker for key $desc")
        else
            warn("Overwriting existing mutator for key $desc")
        end
    end
    LibDescToMutators[desc] = m
end

function find_mutator_for_type{T <: Type}(t::T; findshrinker = false)
    s = nothing
    while s == nothing && t != Any
        mutators = findshrinker ? shrinkers_for_type(t) : mutators_for_type(t)
        if length(mutators) > 0
            return mutators[rand(1:length(mutators))]
        end
        #@show ("not found", t)
        t = supertype(t)
    end
    return nothing
end

find_shrinker_for_type{T <: Type}(t::T) = find_mutator_for_type(t; findshrinker = false)

const PrimitiveNumberTypes = [Int64, Int32, Int16, Int8, Float64]