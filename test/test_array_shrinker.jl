import DataMutators: ArrayShrinker, shrink, HalfArrayShrinker, size_reductions, ArrayElementShrinker

@generator IntArrayGen begin
    start() = Int[rand(1:100) for _ in 0:rand(1:37)]
end
const intArrayGen = IntArrayGen()

@generator FloatArrayGen begin
    start() = begin
        minval = -100.0 + 200 * rand()
        maxval = minval + 100 * rand()
        Float64[rand(minval:maxval) for i in 0:rand(1:37)]
    end
end
const floatArrayGen = FloatArrayGen()

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

        srs = size_reductions(ArrayShrinker(1), floatArrayGen, 100)
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
        @test 0.4 < mean(srs) < 0.6

        srs = size_reductions(HalfArrayShrinker(), floatArrayGen, 100)
        @test 0.4 < mean(srs) < 0.6
    end
end

@testset "ArrayElementShrinker cannot grow & sometimes shrinks" begin
    s = ArrayElementShrinker()
    numshrunk = 0
    for i in 1:100
        a = choose(intArrayGen)
        r = shrink(s, a)
        lenr = length(string(r))
        lena = length(string(a))
        @test lenr <= lena
        numshrunk += ((lenr < lena) ? 1 : 0)
    end
    @test numshrunk > 0 # At least once in 100 tries
end

@testset "picks any of the shrinker if no explicit shrinker given" begin
    a = collect(1:20)
    r = shrink(a)
    @test r != a
    @test length(string(r)) <= length(string(a))
end

@testset "library has shrinkers for arrays of common types" begin
    for t in [Int64, Int32, Int16, Int8]
        a = t[1, rand(1:10)]
        r = shrink(a)
        @test r != a
    end

    a = Float64[1.0, 10*rand()]
    r = shrink(a)
    @test r != a
end

end