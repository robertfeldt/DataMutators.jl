const LibTypeToMutators = Dict{Type, Vector{AbstractDataMutator}}()
const LibDescToMutators = Dict{AbstractString, AbstractDataMutator}()

filter_shrinkers(ms::Vector{AbstractDataMutator}) = filter(m -> typeof(m) <: AbstractDataShrinker, ms)
shrinkers_for_type(t::Type) = filter_shrinkers(mutators_for_type(t))
mutators_for_type(t::Type) = get(LibTypeToMutators, t, AbstractDataMutator[])

# Cached lookups to dir. Cache is emptied whenever there is a new mutator registered.
const CacheTypeToMutators = Dict{Type, Vector{AbstractDataMutator}}()

function register{T <: Type}(m::AbstractDataMutator, t::T, desc = "")
    # Empty cache since we now will need to lookup mutators for types anew.
    empty!(CacheTypeToMutators)

    # Add mutator to library for its type.
    LibTypeToMutators[t] = mutators = mutators_for_type(t)
    push!(mutators, m)

    # Link the description to the mutator.
    if desc != ""
        if haskey(LibDescToMutators, desc)
            styp = typeof(m) <: AbstractDataShrinker ? "shrinker" : "mutator"
            warn("Overwriting existing $styp for key $desc")
        end
        LibDescToMutators[desc] = m
    end
end

function cachemutators!(ms::Vector{AbstractDataMutator}, t::Type)
    global CacheTypeToMutators
    CacheTypeToMutators[t] = ms
end

function find_mutators_for_type{T <: Type}(t::T; onlyshrinkers = false)
    # If the type is in the cache we can just return it. Saves us from having to
    # search in the library again.
    if haskey(CacheTypeToMutators, t)
        ms = CacheTypeToMutators[t]
        return (onlyshrinkers ? filter_shrinkers(ms) : ms)
    end

    # If the type is in the library return the saved mutators after caching them.
    if haskey(LibTypeToMutators, t)
        allms = mutators_for_type(t)
        cachemutators!(allms, t)
        return (onlyshrinkers ? filter_shrinkers(allms) : allms)
    end

    # First search up the type chain
    for tt in SupertypeChainIterator(t)
        allms = mutators_for_type(tt)
        ms = onlyshrinkers ? filter_shrinkers(allms) : allms
        if length(ms) > 0
            cachemutators!(allms, t)
            return ms
        end
        #@show ("not found, supertype search", tt)
    end

    # If nothing found we also search up the subtype/supertype chain.
    for tt in SubSupertypeChainIterator(t)
        allms = mutators_for_type(tt)
        ms = onlyshrinkers ? filter_shrinkers(allms) : allms
        if length(ms) > 0
            cachemutators!(allms, t)
            return ms
        end
        #@show ("not found, subsupertype search", tt)
    end

    return nothing # Indicates that nothing was found...
end

function find_mutator_for_type{T <: Type}(t::T; findshrinker = false)
    ms = find_mutators_for_type(t; onlyshrinkers = findshrinker)
    if ms == nothing || length(ms) < 1
        return nothing
    else
        return StatsBase.sample(ms)
    end
end

find_shrinker_for_type{T <: Type}(t::T) = find_mutator_for_type(t; findshrinker = true)

const PrimitiveNumberTypes = [Int64, Int32, Int16, Int8, Float64]