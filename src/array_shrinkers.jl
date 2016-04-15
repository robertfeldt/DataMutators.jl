immutable ArrayShrinker <: AbstractDataShrinker
  num_elems_to_delete::Function
  ArrayShrinker(fn::Function) = new(fn)
end
ArrayShrinker(numdelete::Integer) = ArrayShrinker((l) -> min(length(l), numdelete))
ArrayShrinker() = ArrayShrinker(1)
halfsize(a) = ceil(Integer, length(a)/2)
HalfArrayShrinker() = ArrayShrinker(halfsize)

function shrink{T}(s::ArrayShrinker, a::Vector{T})
  newlen = length(a) - s.num_elems_to_delete(a)
  res = Array(T, newlen)
  # Sort so we keep them in the order they had in orig array
  keepidxs = sort(shuffle(collect(1:length(a)))[1:newlen])
  for i in 1:newlen
    res[i] = a[keepidxs[i]]
  end
  res
end

DataShrinkers.register(ArrayShrinker(1),    Array, "remove one random element of an array")
DataShrinkers.register(HalfArrayShrinker(), Array, "remove half of the elements of an array")

# Also register for arrays of specific sub-types
PrimitiveTypes = [Int, Real, Float64]
for p in PrimitiveTypes
  DataShrinkers.register(ArrayShrinker(1),    Vector{p}, "remove one random element of an array of $p")
  DataShrinkers.register(HalfArrayShrinker(), Vector{p}, "remove half of the elements of an array of $p")
end