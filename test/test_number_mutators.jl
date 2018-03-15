using DataMutators: SubtractNumberMutator, mutate, mutation, apply!

@testset "Number mutators and shrinkers" begin

@testset "Subtract 1 mutator" begin
    @testset "explicit mutator arg" begin
        @testset "Integer" begin
            s = SubtractNumberMutator{Int64}(1)
            a = 2
            r = mutate(s, a)
            @test r == 1
            @test typeof(r) == typeof(a)
        end

        @testset "Integer" begin
            s = SubtractNumberMutator{Float64}(1.0)
            a = 2.0
            r = mutate(s, a)
            @test r == 1.0
            @test typeof(r) == typeof(a)
        end
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

@testset "library can mutate all basic number types " begin
    a = Int(1)
    @test mutate(a) != a

    a2 = Int32(3)
    @test mutate(a2) != a2

    a3 = Int16(11)
    @test mutate(a3) != a3

    a4 = Int8(56)
    @test mutate(a4) != a4

    a5 = Float64(1.6792)
    @test mutate(a5) != a5
end

end