const LibTypeToMutators = Dict{Type, Vector{AbstractDataMutator}}()
const LibDescToMutators = Dict{AbstractString, AbstractDataMutator}()

shrinkers_for_type(t::Type) = filter_shrinkers(mutators_for_type(t))
function mutators_for_type(t::Type)
    global LibTypeToMutators
    get(LibTypeToMutators, t, AbstractDataMutator[])
end

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

function find_mutators_for_type{T <: Type}(t::T)
    # If the type is in the cache we can just return it. Saves us from having to
    # search in the library again.
    if haskey(CacheTypeToMutators, t)
        ms = CacheTypeToMutators[t]
        return ms
    end

    # If the type is in the library return the saved mutators after caching them.
    if haskey(LibTypeToMutators, t)
        allms = mutators_for_type(t)
        cachemutators!(allms, t)
        return allms
    end

    # First search up the type chain
    for tt in SupertypeChainIterator(t)
        allms = mutators_for_type(tt)
        if length(allms) > 0
            cachemutators!(allms, t)
            return allms
        end
        #@show ("not found, supertype search", tt)
    end

    # If nothing found we also search up the subtype/supertype chain.
    for tt in SubSupertypeChainIterator(t)
        allms = mutators_for_type(tt)
        if length(allms) > 0
            cachemutators!(allms, t)
            return allms
        end
        #@show ("not found, subsupertype search", tt)
    end

    return nothing # Indicates that nothing was found...
end

function find_mutator_for_type{T <: Type}(t::T; mutatorSelectionContext = DefaultMutatorSelectionContext())
    ms = find_mutators_for_type(t)
    if ms == nothing || length(ms) < 1
        return nothing
    else
        return select(mutatorSelectionContext, ms)
    end
end

function find_mutator_for_datum(d; mutatorSelectionContext = DefaultMutatorSelectionContext())
    find_mutator_for_type(typeof(d); mutatorSelectionContext = mutatorSelectionContext)
end

# To find mutations for a datum we select some mutator for its type and then
# get mutations from it.
function mutations(d; mutatorSelectionContext = DefaultMutatorSelectionContext())
    mutator = find_mutator_for_datum(d; mutatorSelectionContext = mutatorSelectionContext)
    if mutator == nothing
        error("Did not find a mutator for $d")
    end
    mutations(mutator, d)
end

const PrimitiveNumberTypes = [Int64, Int32, Int16, Int8, Float64]
