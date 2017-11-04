using DataMutators: deleteat, DeleteChars, CopyChars, MutateStringPattern, mutate_int_string

@testset "String mutators" begin

@testset "deleteat" begin
    @test deleteat("abc", Int64[]) == "abc"

    @test deleteat("abc", Int64[1]) == "bc"
    @test deleteat("abc", Int64[2]) == "ac"
    @test deleteat("abc", Int64[3]) == "ab"   

    # We just skip indices outside the valid range; they have no effect.
    @test deleteat("abc", Int64[1, 4]) == "bc"
    @test deleteat("abc", Int64[5, 2]) == "ac"
    @test deleteat("abc", Int64[7, 3, 10]) == "ab"    
end

@testset "DeleteChars(1)" begin
    dc = DeleteChars(1)

    @test shrink(dc, "") == ""
    @test length(shrink(dc, "arne")) == 3

    for _ in 1:10
        s = randstring(rand(1:42))
        r = shrink(dc, s)
        @test length(r) == length(s) - 1
        for c in r
            @test in(c, s)
        end
    end
end

@testset "DeleteChars(2)" begin
    dc = DeleteChars(2)

    @test shrink(dc, "") == ""
    @test shrink(dc, "a") == ""
    @test shrink(dc, "ab") == ""

    @test length(shrink(dc, "arne")) == 2
end

@testset "CopyChars(1)" begin
    cc = CopyChars(1)

    s = "abc"
    for _ in 1:10
        r = mutate(cc, s)
        @test length(r) == length(s)
        @test length(unique(r)) == length(unique(s)) - 1
    end
end

@testset "CopyChars(2)" begin
    cc = CopyChars(2)

    s = "abcd"
    for _ in 1:10
        r = mutate(cc, s)
        @test length(r) == length(s)
        @test length(unique(r)) < length(unique(s))
    end
end

@testset "mutate_int_string" begin
    @test mutate_int_string("12", i -> i-1) == "11"
    @test mutate_int_string("12", i -> i+1) == "13"

    @test mutate_int_string("19", i -> i+1) == "20"
    @test mutate_int_string("11", i -> i-1) == "10"

    @test mutate_int_string("10", i -> i-1, "0") == "09"
    @test mutate_int_string("10", i -> i-1)      == "09"

    @test mutate_int_string("10", i -> i-1, "") == "9"

    @test mutate_int_string("9", i -> i+1, "0", false) == "10"
    @test mutate_int_string("9", i -> i+1, "",  false) == "10"

    @test mutate_int_string("9", i -> i+1, "0", true) == "0" # Chopped since too long
end

@testset "MutateStringPattern" begin
    # Decrease char digits
    m = MutateStringPattern(r"\d", is -> string(max(0, parse(Int, is)-1)))

    @test mutate(m, "") == ""
    @test mutate(m, "a") == "a"
    @test mutate(m, "abcd") == "abcd"

    @test mutate(m, "1") == "0"
    @test mutate(m, "a1") == "a0"
    @test mutate(m, "a2b") == "a1b"
    @test in(mutate(m, "a3b4c"), Any["a3b3c", "a2b4c"])
    @test in(mutate(m, "a56b"), Any["a46b", "a55b"])
end

@testset "Picks some string mutators if none explicitly given" begin
    s = "arne"
    r = mutate(s)
    @test r != s
end

end
