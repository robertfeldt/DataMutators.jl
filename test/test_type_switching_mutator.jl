using DataMutators: TypeSwitchingMutator, mutate

@testset "TypeSwitchingMutator" begin

    @testset "switching to Int" begin
        m = TypeSwitchingMutator{Int64}([0, 1])
        @test in(mutate(m, 1.3), [0, 1])
    end

    @testset "switching to Float" begin
        vals = [0.0, 1.0, -1.0]
        m = TypeSwitchingMutator{Float64}(vals)
        @test in(mutate(m, "a"), vals)
    end

end