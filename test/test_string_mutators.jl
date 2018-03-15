using DataMutators: DeleteChars, mutate_int_string, MutateStringPattern, CopyChars
using DataMutators: DecreaseIntKeepingSize, DecreaseInt, IncreaseIntKeepingSize

@testset "String mutators" begin

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

function prevdigit{S <: AbstractString}(numchar::S)
    i = parse(Int, numchar)
    i = (i == 0) ? 9 : (i-1)
    string(i)
end

@testset "MutateStringPattern" begin
    # Decrease char digits
    m = MutateStringPattern(r"\d", prevdigit)
    @test mutate(m, "") == ""
    @test mutate(m, "a") == "a"
    @test mutate(m, "abcd") == "abcd"
    @test mutate(m, "1") == "0"
    @test mutate(m, "0") == "9"
    @test mutate(m, " 3") == " 2"
    @test mutate(m, "a7") == "a6"
    @test mutate(m, "a1") == "a0"
    @test mutate(m, "a2b") == "a1b"
    @test in(mutate(m, "a3b4c"), Any["a3b3c", "a2b4c"])
    @test in(mutate(m, "a56b"), Any["a46b", "a55b"])
end

@testset "DecreaseIntsKeepingSize" begin
    @test mutate(DecreaseIntKeepingSize, "1") == "0"
    @test mutate(DecreaseIntKeepingSize, "10") == "09"
    @test mutate(DecreaseIntKeepingSize, "100") == "099"
    @test mutate(DecreaseIntKeepingSize, "1000") == "0999"
    @test mutate(DecreaseIntKeepingSize, "987") == "986"
    @test mutate(DecreaseIntKeepingSize, "abc465") == "abc464"
    @test in(mutate(DecreaseIntKeepingSize, "abc4d65"), ["abc4d64", "abc3d65"])
    @test in(mutate(DecreaseIntKeepingSize, "a4d6e5"), ["a4d6e4", "a4d5e5", "a3d6e5"])
end

@testset "DecreaseInt" begin
    @test mutate(DecreaseInt, "1") == "0"
    @test mutate(DecreaseInt, "10") == "9"
    @test mutate(DecreaseInt, "100") == "99"
    @test mutate(DecreaseInt, "1000") == "999"
    @test mutate(DecreaseInt, "987") == "986"
    @test mutate(DecreaseInt, "abc465") == "abc464"
    @test in(mutate(DecreaseInt, "abc4d65"), ["abc4d64", "abc3d65"])
    @test in(mutate(DecreaseInt, "a4d6e5"), ["a4d6e4", "a4d5e5", "a3d6e5"])
end

@testset "IncreaseIntsKeepingSize" begin
    @test mutate(IncreaseIntKeepingSize, "1") == "2"
    @test mutate(IncreaseIntKeepingSize, "9") == "0"
    @test mutate(IncreaseIntKeepingSize, "10") == "11"
    @test mutate(IncreaseIntKeepingSize, "99") == "00"
    @test mutate(IncreaseIntKeepingSize, "999") == "000"
    @test mutate(IncreaseIntKeepingSize, "987") == "988"
    @test mutate(IncreaseIntKeepingSize, "abc465") == "abc466"
    @test in(mutate(IncreaseIntKeepingSize, "abc4d65"), ["abc4d66", "abc5d65"])
    @test in(mutate(IncreaseIntKeepingSize, "a4d6e5"), ["a4d6e6", "a4d7e5", "a5d6e5"])
end

@testset "Picks some string mutators if none explicitly given" begin
    s = "arne"
    r = mutate(s)
    @test r != s
end

end
