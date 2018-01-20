abstract TypeChainIterator

immutable SupertypeChainIterator <: TypeChainIterator
    origtype::Type
end

Base.start(i::SupertypeChainIterator) = i.origtype

Base.next(i::SupertypeChainIterator, t) = (t, (t == Any) ? nothing : supertype(t))

Base.done(i::SupertypeChainIterator, t) = t == nothing

function Base.collect(iter::TypeChainIterator)
    types = Type[]
    for t in iter
        push!(types, t)
    end
    types
end

immutable SubSupertypeChainIterator <: TypeChainIterator
    origtype::DataType
end

# State is the number of the current parameter of the origtype to consider and its
# SupertypeChainIterator. Starts at 0 to indicate that we have not yet considered a param.
Base.start(i::SubSupertypeChainIterator) = (0, Type[])

function Base.done(i::SubSupertypeChainIterator, t::Tuple{Int, Vector{Type}})
    paramnum, supertypechain = t
    length(supertypechain) == 0 && !hastypeparamsleft(i, paramnum)
end

function hastypeparamsleft(i::SubSupertypeChainIterator, afterparam::Int)
    l = length(i.origtype.parameters)
    afterparam < l && any(idx -> paramisdatatype(i, idx), (afterparam+1:l))
end

paramisdatatype(i::SubSupertypeChainIterator, idx::Int) = typeof(i.origtype.parameters[idx]) == DataType

roottype(typ::Type) =
    VERSION < v"0.5.100" ? typ.name.primary : Compat.TypeUtils.typename(typ).wrapper

function replacetypeparam(t::Type, i::Int, replacetype::Type)
    params = collect(t.parameters)
    params[i] = replacetype
    roottype(t){params...}
end

function Base.next(i::SubSupertypeChainIterator, t::Tuple{Int, Vector{Type}})
    paramnum, supertypechain = t

    if length(supertypechain) < 1
        paramnum += 1
        while !paramisdatatype(i, paramnum)
            paramnum += 1
        end
        nextorigsubtype = i.origtype.parameters[paramnum]
        supertypechain = collect(SupertypeChainIterator(nextorigsubtype))
    end

    nextsubsupertype = shift!(supertypechain)
    item = replacetypeparam(i.origtype, paramnum, nextsubsupertype)

    return (item, (paramnum, supertypechain))
end