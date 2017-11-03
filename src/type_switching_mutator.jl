immutable TypeSwitchingMutator{T} <: AbstractDataMutator
  targets::Vector{T}
end
mutate{T}(m::TypeSwitchingMutator{T}, a) = m.targets[rand(1:length(m.targets))]

DataMutators.register(TypeSwitchingMutator{Int}([0,1]), Any, 
    "switch to Integer boundary value from value of any type")
DataMutators.register(TypeSwitchingMutator{String}(["","a","1"]), Any, 
    "switch to String boundary value from value of any type")