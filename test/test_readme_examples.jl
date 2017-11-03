using DataMutators: TypeSwitchingMutator, mutate

prop_last_is_first(l) = last(l) == first(buggyreverse(l))

@testset "README examples" begin

@testset "buggyreverse shrinking example" begin
    fd = [1, 2, 3, 4]
    res = shrink(fd, prop_last_is_first)
    @test sort(res) == [0, 1]
end

end
