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

immutable ArrayElementShrinker <: AbstractDataShrinker
end
function shrink{T}(s::ArrayElementShrinker, a::Vector{T})
  res = deepcopy(a)
  idx = rand(1:length(a))
  res[idx] = shrink(a[idx])
  res
end

DataShrinkers.register(ArrayShrinker(1),       Array, "remove one random element of an array")
DataShrinkers.register(HalfArrayShrinker(),    Array, "remove half of the elements of an array")
DataShrinkers.register(ArrayElementShrinker(), Array, "shrink an element of an array")
for p in PrimitiveNumberTypes
  DataShrinkers.register(ArrayShrinker(1),       Vector{p}, "remove one random element of an array of $p")
  DataShrinkers.register(HalfArrayShrinker(),    Vector{p}, "remove half of the elements of an array of $p")
  DataShrinkers.register(ArrayElementShrinker(), Vector{p}, "shrink an element of an array of $p")
end