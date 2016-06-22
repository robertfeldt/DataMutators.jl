using DataMutators: shrink

# Method under test with (unlikely) seeded fault:
buggyreverse(l) = (length(l) < 5) ? l : reverse(l)

# Property being tested
prop_rev_invariant(l) = buggyreverse(l)[end] == l[1]

@testset "shrink_until" begin
    # Lets say our auto testing tool has found the following datum that violates the spec
    d = [11,42, 954, 32]

    # We can now shrink it like so
    smaller = shrink(d, prop_rev_invariant)
    @test length(string(smaller)) < length(string(d))
    #@show d
    #@show smaller
end