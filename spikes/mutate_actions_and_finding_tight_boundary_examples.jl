# Rather than creating DataMutators that directly changes a datum
# they instead create MutateActions that when executed on a datum
# mutates it. MutateActions can be atomic or complex; the latter
# can also be expanded into atomic actions. This allows us to
# step through atomic changes and really know which action is the
# critical one in forcing a certain change in a property etc.
# Here we try out this design in a spike.

abstract MutateAction;

immutable ArrayDelete <: MutateAction
    idx::Int
end
apply!{ET}(ad::ArrayDelete, d::Vector{ET}) = deleteat!(d, ad.idx)

abstract AbstractDataMutator
abstract AbstractDataShrinker <: AbstractDataMutator

immutable ArrayShrinker <: AbstractDataShrinker
    num_elems_to_delete::Function
    ArrayShrinker(fn::Function) = new(fn)
end
ArrayShrinker(numdelete::Integer) = ArrayShrinker((l) -> min(length(l), numdelete))
ArrayShrinker() = ArrayShrinker(1)
halfsize(a) = ceil(Integer, length(a)/2)
HalfArrayShrinker() = ArrayShrinker(halfsize)

# Traditional way to implement shrink
function oldshrink{T}(s::ArrayShrinker, a::Vector{T})
    newlen = length(a) - s.num_elems_to_delete(a)
    res = Array(T, newlen)
    # Sort so we keep them in the order they had in orig array
    keepidxs = sort(shuffle(collect(1:length(a)))[1:newlen])
    for i in 1:newlen
      res[i] = a[keepidxs[i]]
    end
    res
end

# New way is to get the actions needed.
function actions{T}(s::ArrayShrinker, a::Vector{T})
    numdelete = s.num_elems_to_delete(a)
    if numdelete > 0
        deleteidxs = sort(shuffle(collect(1:length(a)))[1:numdelete])
        # Note that we must subtract 1 per step since previous ArrayDelete actions 
        # have already shortened the array.
        return MutateAction[ArrayDelete(deleteidxs[i] + 1 - i) for i in 1:numdelete]
    else
        return MutateAction[]
    end
end

# and then have a general shrink method that applies the actions
shrink(m::AbstractDataMutator, datum) = apply(actions(m, datum), datum)
apply(as::Vector{MutateAction}, datum) = apply!(as, deepcopy(datum))
function apply!(as::Vector{MutateAction}, datum)
    for action in as
        apply!(action, datum)
    end
    return datum
end

# Now let's try the simple example used in testing and README
buggyreverse(l) = (length(l) < 5) ? l : reverse(l)
prop_last_is_first(l) = last(l) == first(buggyreverse(l))
d1 = [11,42, 954, 32, 765, 17]

# We run the shrink steps manually to avoid implementing the complex, top-level shrink API
# in this spike:
s = ArrayShrinker(3)
as1 = actions(s, d1)
d2 = apply(as1, d1)
# But now the property shifted from true to false
prop_last_is_first(d1) # true
prop_last_is_first(d2) # false
# so we want to "play back" the atomic actions to see which
# of them are critical for the property transition. We try the first one.
d2a = apply(as1[1:1], d1)
prop_last_is_first(d2a) # still true so not enough with first action
# try the second action
d2b = apply(as1[2:2], d2a)
prop_last_is_first(d2b) # false => we need actions 1 and 2
# So we now have a "tighter" example of the property transition
# and now a series of atomic actions to change the former to the latter.
tightexample = (d2a, d2b, as1[2:2])

# With such a tight example we can now try to simplify it further
# since we know how to come from the former to the latter. In this case
# we can for example use an ArrayElementMutator and an IntShrinker.
# Here we implement this simplification in code instead to keep this spike
# shorter.
function array_of_int_shrinker{T}(d::Vector{T}, as::Vector{MutateAction}, prop::Function)
    d = deepcopy(d)
    for i in shuffle(1:length(d))
        while d[i] > 0 && prop(d) != prop(apply(as, d))
            d[i] = d[i] - 1
        end
        if prop(d) == prop(apply(as, d))
            d[i] = d[i] + 1 # back up if we went too far
        end
    end
    return d
end

simpler = array_of_int_shrinker(tightexample[1], tightexample[3], prop_last_is_first)
simpleryet = array_of_int_shrinker(simpler, tightexample[3], prop_last_is_first)
# We know have a very small and tight example that shows when the buggyreverse function
# does not fulfill the property:
# When we change [1, 0, 0, 0, 0] by deleting the 3rd element the property goes from true to false.
# In this case it actually does not matter which element we delete as long as its not the first one.
# We can thus expand the description by now searching in the space of atomic mutations:
