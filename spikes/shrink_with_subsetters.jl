# Spikee trying to get different shrinkers "for free" by giving different ways to
# iterate over elements of an object

# If we want to shrink an array it is easy since we know how big it is and we can
# easily state different subsets of its 1:len indices and use that to subset.

abstract AbstractDataShrinker

abstract SubsettingShrinker <: AbstractDataShrinker
function shrink{T <: Any}(s::SubsettingShrinker, a::AbstractArray{T,1})
    idxs = include_indices(s, length(a))
    newa = Array(eltype(a), length(idxs))
    for i in 1:length(idxs)
        newa[i] = a[idxs[i]]
    end
    newa
end

function shrink{K <: Any, V <: Any}(s::SubsettingShrinker, d::Associative{K,V})
    idxs = include_indices(s, length(d))
    newd = Dict{K,V}()
    for (i, k) in enumerate(keys(d))
        if in(i, idxs)
            newd[k] = d[k]
        end
    end
    newd
end

random_indices(n, num) = sort(shuffle(collect(1:n))[1:num])

a = Symbol[:a, :b, :c, :d]
si = SubsetIterator{typeof(a)}(enumerate(a), random_indices(length(a), 2))

function shrink{T <: Any}(s::SubsettingShrinker, e::Enumerate{T}, o)
    idxs = include_indices(s, length(e))
    itr = SubsetIterator{T}(e, idxs)
    rebuild_from_iterator(o, itr)
end

immutable ShrinkOneRandElement <: SubsettingShrinker; end
include_indices(s::ShrinkOneRandElement, len::Int) = random_indices(len, len-1)

immutable ShrinkLastElement <: SubsettingShrinker; end
include_indices(s::ShrinkLastElement, len::Int) = collect(1:(len-1))

immutable ShrinkFirstElement <: SubsettingShrinker; end
include_indices(s::ShrinkFirstElement, len::Int) = collect(2:len)

immutable RandomSubsetRelSizeShrinker <: SubsettingShrinker
    sizefactor::Float64 # How much smaller the length of the new datum should be
end
newlen(s::RandomSubsetRelSizeShrinker, oldlen::Int) = max(0, round(Int, s.sizefactor * oldlen))
include_indices(s::RandomSubsetRelSizeShrinker, len::Int) = random_indices(len, newlen(s, len))
HalfingSizeShrinker() = RandomSubsetRelSizeShrinker(0.5)


# Normal lib methods
const LibTypeToShrinkers = Dict{Type, Vector{AbstractDataShrinker}}()
const LibDescToShrinker = Dict{AbstractString, AbstractDataShrinker}()

shrinkers_for_type(t::Type) = get!(LibTypeToShrinkers, t, AbstractDataShrinker[])

function register{T <: Type}(s::AbstractDataShrinker, t::T, desc = "")
    shrinkers = shrinkers_for_type(t)
    push!(shrinkers, s)

    if haskey(LibDescToShrinker, desc)
        warn("Overwriting existing shrinker desc for key $desc")
    end
    LibDescToShrinker[desc] = s
end

function description(s::AbstractDataShrinker)
    for (desc, shr) in LibDescToShrinker
        if shr === s
            return desc
        end
    end
end

function find_shrinker_for_type{T <: Type}(t::T)
    prevt = origt = t
    s = nothing
    while s == nothing && t != Any
        shrinkers = shrinkers_for_type(t)
        if length(shrinkers) > 0
            return shrinkers[rand(1:length(shrinkers))]
        end
        prevt = t
        t = super(t)
    end

    # If we found no shrinkers and this is an AbstractArray we copy the general
    # abstract array shrinkers over. Note that this is static for now so if new
    # abstract array shrinkers are added later they will not carry over!
    if prevt <: AbstractArray
        # TODO: fix if prevt has dims over 1
        return update_with_shrinkers_of_type(origt, AbstractArray{Any,1}, " of elements of type $(eltype(origt))")
    end

    # If we found no shrinkers and this is an AbstractArray we copy the general
    # abstract array shrinkers over. Note that this is static for now so if new
    # abstract array shrinkers are added later they will not carry over!
    if prevt <: Associative
        # TODO: fix if prevt has dims over 1
        ktype, vtype = origt.parameters
        return update_with_shrinkers_of_type(origt, Associative{Any,Any}, " from $(ktype) to $(vtype)")
    end

    return nothing
end

function update_with_shrinkers_of_type(newtype::Type, oldtype::Type, suffixdesc::AbstractString)
    shrinkers = shrinkers_for_type(oldtype)
    for as in shrinkers
        register(deepcopy(as), newtype, description(as) * suffixdesc)
    end
    if length(shrinkers) > 0
        return find_shrinker_for_type(newtype)
    end
end

# Now register a one rand element shrinker for abstract arrays
register(ShrinkOneRandElement(), AbstractArray{Any,1}, "delete one random element of array")
register(HalfingSizeShrinker(), AbstractArray{Any,1}, "delete half of the elements of an array")
register(ShrinkLastElement(), AbstractArray{Any,1}, "delete last element of an array")
register(ShrinkFirstElement(), AbstractArray{Any,1}, "delete first element of an array")

register(ShrinkOneRandElement(), Associative{Any,Any}, "delete one random pair of dict")
register(HalfingSizeShrinker(), Associative{Any,Any}, "delete half of the pairs of dict")

# Let's try and shrink this array
a = collect(1:5)
s = find_shrinker_for_type(typeof(a))
a2 = shrink(s, a)
a3 = shrink(s, a2)
a4 = shrink(s, a3)

d = Dict{Symbol, Int}(:a => 1, :b => 2, :c => 3, :d => 4)
s = find_shrinker_for_type(typeof(d))
d2 = shrink(s, d)