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
