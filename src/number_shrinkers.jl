immutable SubtractNumberShrinker <: AbstractDataShrinker
  stepsize
  SubtractNumberShrinker(stepsize = 1) = new(stepsize)
end
shrink{N <: Number}(s::SubtractNumberShrinker, a::N) = N(a - s.stepsize)

immutable MultiplyNumberShrinker <: AbstractDataShrinker
  factor
end
shrink{N <: Integer}(s::MultiplyNumberShrinker, a::N) = round(N, a * s.factor)
shrink{N <: Real}(s::MultiplyNumberShrinker, a::N) = N(a * s.factor)

for p in PrimitiveNumberTypes
  DataShrinkers.register(SubtractNumberShrinker(1),   p, "subtract 1 from number of type $p")
  DataShrinkers.register(MultiplyNumberShrinker(0.5), p, "half a number of type $p")
end