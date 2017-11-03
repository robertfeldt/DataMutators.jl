using DataMutators: SubtractNumberShrinker

@testset "Number shrinkers" begin

@testset "Subtract 1 shrinker" begin
    @testset "explicit shrinker arg" begin
        s = SubtractNumberShrinker(1)
        a = 2
        r = shrink(s, a)
        @test r == 1
        @test typeof(r) == typeof(a)

        a2 = 2.0
        r2 = shrink(s, a2)
        @test r2 == 1.0
        @test typeof(r2) == typeof(a2)
    end
end

@testset "library can shrink all basic number types " begin
    a = Int(1)
    @test shrink(a) < a

    a2 = Int32(3)
    @test shrink(a2) < a2

    a3 = Int16(11)
    @test shrink(a3) < a3

    a4 = Int8(56)
    @test shrink(a4) < a4

    a5 = Float64(1.6792)
    @test shrink(a5) < a5
end

end