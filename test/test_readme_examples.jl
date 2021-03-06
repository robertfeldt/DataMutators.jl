using DataMutators: shrink, shrink_until

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
end

@testset "Example 3: buggyreverse shrinking array of data of multiple types" begin
    fd3 = [0, "than", "needed", [1.1, 2, "ab"]]
    #res3, lenred, cnt, strace, dtrace, swtrace = shrink_until(fd3, prop_last_is_first; 
    #            traceDatums = true, traceShrinkers = true, traceSwitches = true)
    res3 = shrink(fd3, prop_last_is_first)
    @test length(res3) == 2
end

end
