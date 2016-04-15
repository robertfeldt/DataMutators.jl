import DataShrinkers: ArrayShrinker, shrink, HalfArrayShrinker

@testset "Array shrinker" begin

@testset "ArrayShrinker(1)" begin
    @testset "explicit shrinker arg" begin
        s = ArrayShrinker(1)
        a = [1,2,3]
        r = shrink(s, a)
        @test length(r) == length(a) - 1

        r2 = shrink(s, r)
        @test length(r2) == length(r) - 1

        r3 = shrink(s, r2)
        @test length(r3) == length(r2) - 1

        # But now we are at the minimum so cannot shrink
        @test length(shrink(s, r3)) == length(r3)
    end
end

@testset "ArrayShrinker(2)" begin
    @testset "explicit shrinker arg" begin
        s = ArrayShrinker(2)
        a = [1,2,3]
        r = shrink(s, a)
        @test length(r) == length(a) - 2

        r2 = shrink(s, r)
        @test length(r2) == 0
    end
end

@testset "HalfArrayShrinker" begin
    s = HalfArrayShrinker()
    a = [1,2,3,4]
    r = shrink(s, a)
    @test length(r) == 2

    r2 = shrink(s, r)
    @test length(r2) == 1

    r3 = shrink(s, r2)
    @test length(r3) == 0
end

@testset "no explicit shrinker" begin
    a = collect(1:20)
    r = shrink(a)
    @test length(r) < length(a)
end

end