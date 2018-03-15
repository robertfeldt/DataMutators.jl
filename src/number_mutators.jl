immutable SubtractNumberMutation{N <: Number} <: AtomicMutation
    n::N
end
apply!{N <: Number}(ad::SubtractNumberMutation{N}, d::N) = d - ad.n

immutable SubtractNumberMutator{N <: Number} <: AbstractDataMutator
  stepsize::N
end
mutation{N <: Number}(m::SubtractNumberMutator{N}, d::N; mutatorSelectionContext = DefaultMutatorSelectionContext()) = 
  SubtractNumberMutation{N}(m.stepsize)

immutable MultiplyNumberMutation{N <: Number} <: AtomicMutation
  factor::N
end
apply!{D <: Integer, N <: Number}(mn::MultiplyNumberMutation{N}, d::D) = round(D, d * mn.factor)
apply!{N <: Real}(mn::MultiplyNumberMutation{N}, d::N) = d * mn.factor

immutable MultiplyNumberMutator{N <: Number} <: AbstractDataMutator
  factor::N
end
mutation{N1 <: Number, N2 <: Number}(m::MultiplyNumberMutator{N1}, d::N2; mutatorSelectionContext = DefaultMutatorSelectionContext()) = 
  MultiplyNumberMutation{N1}(m.factor)
isshrinker{N <: Number}(m::MultiplyNumberMutator{N}) = abs(m.factor) < 1.0 # Only a shrinker if we go towards 0

for p in PrimitiveNumberTypes
  DataMutators.register(SubtractNumberMutator{p}(1),   p, "subtract 1 from number of type $p")
  DataMutators.register(MultiplyNumberMutator{Float64}(0.5), p, "half a number of type $p")
end