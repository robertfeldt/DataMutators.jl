import DataShrinkers: ArrayShrinker, shrink, HalfArrayShrinker, size_reductions

@generator IntArrayGen begin
    start = Int[rand(1:100) for i in 0:rand(1:37)]
end
const intArrayGen = IntArrayGen()

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

    @testset "mean size reduction is below 50% when arrays typically have more than a few elements" begin
        srs = size_reductions(ArrayShrinker(1), intArrayGen, 100)
        @test mean(srs) < 0.5
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

    @testset "mean size reduction is around to 50%" begin
        srs = size_reductions(HalfArrayShrinker(), intArrayGen, 100)
        @test 0.3 < mean(srs) < 0.7
    end
end

@testset "no explicit shrinker" begin
    a = collect(1:20)
    r = shrink(a)
    @test length(r) < length(a)
end

end