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

sample{T}(a::Vector{T}) = length(a) >= 1 ? a[rand(1:length(a))] : nothing

function find_shrinker_for_type{T <: Type}(t::T)
    s = nothing
    while s == nothing && t != Any
        shrinkers = shrinkers_for_type(t)
        if length(shrinkers) > 0
            return shrinkers[rand(1:length(shrinkers))]
        end
        t = super(t)
    end
    return nothing
end

const PrimitiveNumberTypes = [Int64, Int32, Int16, Int8, Float64]