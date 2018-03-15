immutable ReplaceSubstrMutation <: AtomicMutation
    startpos::Int
    len::Int
    insertstr::String
end
function apply!{S <: String}(m::ReplaceSubstrMutation, s::S)
    s[1:(m.startpos-1)] * m.insertstr * s[(m.startpos+m.len):end]
end

# Deleting is just a special case of replacing with an empty string.
DeleteCharMutation(idx::Int) = ReplaceSubstrMutation(idx, 1, "")

immutable DeleteChars <: AbstractDataShrinker
    numchars::Int
end
function mutations{S <: String}(m::DeleteChars, s::S; mutatorSelectionContext = DefaultMutatorSelectionContext())
    len = length(s)
    numtodelete = min(m.numchars, len)
    indices = sort(StatsBase.sample(1:len, numtodelete; replace=false))
    res = AbstractMutation[]
    for i in 1:length(indices)
        push!(res, DeleteCharMutation(indices[i]+1-i))
    end
    return res
end

DataMutators.register(DeleteChars(1), String, "remove one char of a string")

immutable CopyChars <: AbstractDataMutator
    numchars::Int
end
function mutations{S <: String}(m::CopyChars, s::S; mutatorSelectionContext = DefaultMutatorSelectionContext())
    len = length(s)
    numindices = min(2*m.numchars, len)
    indices = StatsBase.sample(1:len, numindices; replace=false)

    if length(indices) > 0
        res = AbstractMutation[]
        i = 1
        while i+1 <= numindices
            ci = indices[i+1]
            push!(res, ReplaceSubstrMutation(indices[i], 1, s[ci:ci]))
            i += 1
        end
        return res
    else
        return AbstractMutation[NoMutation()]
    end
end

DataMutators.register(CopyChars(1), String, "replace one char of a string with another char from that string")

# We should generalize the type search so that we do not have to add
# these complex types. Introduce a subsupertype which supertypes one of the
# subtypes rather than the outer type?
DataMutators.register(ArrayShrinker(1),       AbstractArray{String,1}, "remove one random element of a String array")
DataMutators.register(HalfArrayShrinker(),    AbstractArray{String,1}, "remove half of the elements of a String array")
DataMutators.register(ArrayElementShrinker(), AbstractArray{String,1}, "shrink an element of a String array")

""" Mutate a pattern of a string matching a regexp """
immutable MutateStringPattern <: AbstractDataMutator
    patternRE::Regex      # The RE to match the pattern.
    replaceFn::Function   # Function that takes the matched pattern and returns a string to replace it with.
end

function mutation{S <: String}(m::MutateStringPattern, s::S; mutatorSelectionContext = DefaultMutatorSelectionContext())
    matches = collect(eachmatch(m.patternRE, s))

    if length(matches) > 0
        rm = StatsBase.sample(matches)
        matchlen = length(rm.match)
        replacement = m.replaceFn(rm.match)
        return ReplaceSubstrMutation(rm.offset, matchlen, replacement)
    else
        return NoMutation()
    end
end

function mutate_int_string{S <: AbstractString}(intstr::S, updateFn::Function, padding = "0", keepsize=true)
    newint = updateFn(parse(Int, intstr))
    newstr = string(newint)
    nummissing = length(intstr) - length(newstr)
    if nummissing > 0
        return padding^(nummissing) * newstr
    elseif nummissing < 0 && keepsize # We need to use only last part since it became longer
        return newstr[(abs(nummissing)+1):end]
    else
        return newstr
    end
end

const DecreaseIntKeepingSize = MutateStringPattern(r"\d+", is -> mutate_int_string(is, i -> i-1, "0"))
const DecreaseInt = MutateStringPattern(r"\d+", is -> mutate_int_string(is, i -> i-1, ""))
const IncreaseIntKeepingSize = MutateStringPattern(r"\d+", is -> mutate_int_string(is, i -> i+1, "0"))
const IncreaseInt = MutateStringPattern(r"\d+", is -> mutate_int_string(is, i -> i+1, ""))

DataMutators.register(DecreaseIntKeepingSize, String, "decrease value of an int sequence within a string, without decreasing length of the string")
DataMutators.register(DecreaseInt, String, "decrease value of an int sequence within a string")
DataMutators.register(IncreaseIntKeepingSize, String, "increase value of an int sequence within a string, without decreasing length of the string")
DataMutators.register(IncreaseInt, String, "increase value of an int sequence within a string")
