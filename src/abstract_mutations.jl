abstract AbstractMutation
abstract AtomicMutation <: AbstractMutation

# All mutations must implement an apply! method
apply!(m::AbstractMutation, datum) = error("Not yet implemented!")

apply{M <: AbstractMutation}(as::Vector{M}, datum) = apply!(as, deepcopy(datum))

function apply!{M <: AbstractMutation}(ms::Vector{M}, datum)
    for mutation in ms
        datum = apply!(mutation, datum) # We must assign here since can be simple types like Int64 that are immutable
    end
    return datum
end

# Default is that mutations cannot be expanded, i.e. are atomic.
canexpand(m::AbstractMutation) = false

# The expansion is by default a list of only the mutation => it is by default atomic.
expansion(m::AbstractMutation) = AbstractMutation[m]

# Expand a mutation to a vector of simpler mutations
expand{M <: AbstractMutation}(m::M; full = false) = canexpand(m) ? expandto!(m, M[]; full = full) : M[m]

abstract ComplexMutation <: AbstractMutation
canexpand(m::ComplexMutation) = true

function expandto!{CM <: ComplexMutation, AM <: AbstractMutation}(cm::CM, res::Vector{AM}; full = false)
    for m in expansion(cm)
        if full && m != cm
            expandto!(m, res; full = true)
        else
            push!(res, m)
        end
    end
    return res
end

immutable NoMutation <: AtomicMutation
end
apply!(m::NoMutation, datum) = datum
