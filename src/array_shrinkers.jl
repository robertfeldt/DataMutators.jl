immutable ArrayDeleteMutation <: AtomicMutation
  idx::Int
end
apply!{T}(ad::ArrayDeleteMutation, d::Vector{T}) = deleteat!(d, ad.idx)

immutable ArrayShrinker <: AbstractDataShrinker
  num_elems_to_delete::Function # Function from array to be shrunk to num elems to delete
end
ArrayShrinker(numdelete::Integer) = ArrayShrinker((l) -> min(length(l), numdelete))
ArrayShrinker() = ArrayShrinker(1)
halfsize(a) = ceil(Integer, length(a)/2)
HalfArrayShrinker() = ArrayShrinker(halfsize)

function mutations{T}(s::ArrayShrinker, a::Vector{T}; mutatorSelectionContext = DefaultMutatorSelectionContext())
  numdelete = s.num_elems_to_delete(a)
  if numdelete > 0
      deleteidxs = sort(shuffle(collect(1:length(a)))[1:numdelete])
      # Note that we must subtract 1 per step since previous ArrayDeleteMutations 
      # have already shortened the array.
      return AbstractMutation[ArrayDeleteMutation(deleteidxs[i] + 1 - i) for i in 1:numdelete]
  else
      return AbstractMutation[]
  end
end

immutable ArrayElementMutation <: AtomicMutation
  idx::Int
  elementmuts::Vector{AbstractMutation}
end
function apply!{T}(ae::ArrayElementMutation, d::Vector{T})
  elem = deepcopy(d[ae.idx])
  d[ae.idx] = apply!(ae.elementmuts, elem)
  d
end

immutable ArrayElementShrinker <: AbstractDataShrinker
end
function mutation{T}(s::ArrayElementShrinker, a::Vector{T}; mutatorSelectionContext = DefaultMutatorSelectionContext())
  idx = rand(1:length(a))
  elem = a[idx]
  ArrayElementMutation(idx, mutations(elem; mutatorSelectionContext = mutatorSelectionContext))
end

DataMutators.register(ArrayShrinker(1),       AbstractArray{Any,1}, "remove one random element of an array")
DataMutators.register(HalfArrayShrinker(),    AbstractArray{Any,1}, "remove half of the elements of an array")
DataMutators.register(ArrayElementShrinker(), AbstractArray{Any,1}, "shrink an element of an array")
for p in PrimitiveNumberTypes
  DataMutators.register(ArrayShrinker(1),       Vector{p}, "remove one random element of an array of $p")
  DataMutators.register(HalfArrayShrinker(),    Vector{p}, "remove half of the elements of an array of $p")
  DataMutators.register(ArrayElementShrinker(), Vector{p}, "shrink an element of an array of $p")
end