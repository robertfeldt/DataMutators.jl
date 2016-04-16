using DataShrinkers: shrink_until, shrink

# Buggy method under test
function buggyreverse(l)
  if length(l) < 5 || any(e->isa(e, Array), l)
    l
  else
    reverse(l)
  end
end

# Property being tested
prop_rev_invariant(l) = buggyreverse(l)[end] == l[1]

@testset "shrink_until" begin
    # Lets say our auto testing tool has found the following datum that violates the spec
    d = [11,22,33,44,55,678,1000]

    # We can now shrink it like so
    smaller = shrink(d, prop_rev_invariant)
    @test length(string(smaller)) < length(string(d))
    #@show d
    #@show smaller
end