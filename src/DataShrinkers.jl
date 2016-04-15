module DataShrinkers
export shrink

abstract AbstractDataShrinker

const LibTypeToShrinkers = Dict{Type, Vector{AbstractDataShrinker}}()
const LibDescToShrinker = Dict{AbstractString, AbstractDataShrinker}()

shrinkers_for_type(t::Type) = get(LibTypeToShrinkers, t, AbstractDataShrinker[])

function register{T <: Type}(s::AbstractDataShrinker, t::T, desc = "")
    LibTypeToShrinkers[t] = shrinkers = shrinkers_for_type(t)
    push!(shrinkers, s)
end

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

function shrink(v)
  s = find_shrinker_for_type(typeof(v))
  s == nothing && error("No shrinker found for type $(typeof(v))")
  shrink(s, v)
end

include("array_shrinkers.jl")
end