using DataMutators: shrink, shrink_until

# Method under test with (unlikely) seeded fault:
buggyreverse(l) = (length(l) < 5) ? l : reverse(l)

# Property being tested
prop_first_is_last(l) = buggyreverse(l)[end] == l[1]
function prop_values_reversed(l)
    len = length(l)
    rl = buggyreverse(l)

    if length(rl) != len
        return false
    end

    for i in eachindex(l)
        if l[i] != rl[len + 1 - i]
            return false
        end
    end
    return true
end

@testset "shrink until a property switches from false to true" begin
    # Lets say our auto testing tool has found the following datum that violates the spec
    d = [1, 2, 3, 4]
    @test prop_first_is_last(d) == false

    # We can now shrink it like so
    smaller = shrink(d, prop_first_is_last)
    # and it should be smaller
    @test length(string(smaller)) < length(string(d))
    # and it should have the same value for the property
    @test prop_first_is_last(d) == prop_first_is_last(smaller)

    # Same for another starting value
    d2 = [11,42, 954, 32]
    @test prop_first_is_last(d2) == false
    smaller2 = shrink(d2, prop_first_is_last)
    @test length(string(smaller2)) < length(string(d2))
    @test prop_first_is_last(d2) == prop_first_is_last(smaller2)
end

@testset "shrink until a property switches from true to false" begin
    d = [11,42, 954, 32, 765]
    @test prop_values_reversed(d) == true
    smaller, lr, nr, str, dtr, swtr = shrink_until(d, prop_values_reversed; 
        traceDatums = true, traceSwitches = true)
    @test length(string(smaller)) < length(string(d))
    @test prop_values_reversed(d) == prop_values_reversed(smaller)

    # All datums in the datum sequence should have the same value for the property.
    for sd in dtr
        @test prop_values_reversed(d) == prop_values_reversed(sd)
    end

    # All pairs of datums in the switch trace 
    # should have different property values.
    for (d, d2) in swtr
        @test prop_values_reversed(d) != prop_values_reversed(d2)
    end
end