immutable DeleteChars <: AbstractDataShrinker
    numchars::Int
end

function deleteat(s::String, indices::Array{Int, 1})
    b = IOBuffer()
    for i in 1:length(s)
        if !in(i, indices)
            print(b, s[i])
        end
    end
    takebuf_string(b)
end

deleteat(s::String, i::Int) = deleteat(s, Int64[i])

function shrink(m::DeleteChars, s::String)
    len = length(s)
    numtodelete = min(m.numchars, len)
    indices_to_delete = StatsBase.sample(1:len, numtodelete; replace=false)
    deleteat(s, indices_to_delete)
end

DataMutators.register(DeleteChars(1), String, "remove one char of a string")

immutable CopyChars <: AbstractDataMutator
    numchars::Int
end

function mutate(m::CopyChars, s::String)
    len = length(s)
    numindices = min(2*m.numchars, len)
    indices = StatsBase.sample(1:len, numindices; replace=false)

    nextindex = 1
    b = IOBuffer()
    for i in 1:len
        if ((nextindex + 1) <= numindices) && (i == indices[nextindex])
            print(b, s[indices[nextindex + 1]])
            nextindex += 2
        else
            print(b, s[i])
        end
    end

    takebuf_string(b)
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

function mutate(m::MutateStringPattern, s::String)
    # Find the matching patterns
    matches = collect(eachmatch(m.patternRE, s))

    if length(matches) > 0
        rm = matches[rand(1:length(matches))]
        matchlen = length(rm.match)
        replacement = m.replaceFn(rm.match)
        return s[1:(rm.offset-1)] * replacement * s[(rm.offset+matchlen):end]
    else
        return s # No mutation if no match found
    end
end

function mutate_int_string(intstr::String, updateFn::Function, padding = "0", keepsize=true)
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

const DecreaseIntsKeepingSize = MutateStringPattern(r"\d+", is -> mutate_int_string(is, i -> i-1, "0"))
const DecreaseInts = MutateStringPattern(r"\d+", is -> mutate_int_string(is, i -> i-1, ""))
const IncreaseIntsKeepingSize = MutateStringPattern(r"\d+", is -> mutate_int_string(is, i -> i+1, "0"))
const IncreaseInts = MutateStringPattern(r"\d+", is -> mutate_int_string(is, i -> i+1, ""))

#DataMutators.register(DecreaseIntsKeepingSize, String, "decrease value of an int sequence within a string, without decreasing length of the string")
#DataMutators.register(DecreaseInts, String, "decrease value of an int sequence within a string")
#DataMutators.register(IncreaseIntsKeepingSize, String, "increase value of an int sequence within a string, without decreasing length of the string")
#DataMutators.register(IncreaseInts, String, "increase value of an int sequence within a string")
