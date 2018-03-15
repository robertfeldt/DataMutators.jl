using DataMutators: shrink

prop_last_is_first(l) = last(l) == first(buggyreverse(l))

@testset "README examples" begin

@testset "Example 1: buggyreverse shrinking array of ints" begin
    fd = [1, 2, 3, 4]
    res = shrink(fd, prop_last_is_first)
    @test sort(res) == [0, 1]
end

@testset "Example 2: buggyreverse shrinking array of strings" begin
    fd2 = ["longer", "strings", "than", "needed"]
    res2 = shrink(fd2, prop_last_is_first)
    @test length(res2) == 2
    @test sort(map(length, res2)) == [0, 1]
end

end
