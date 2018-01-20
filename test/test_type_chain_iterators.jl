using DataMutators: SupertypeChainIterator, SubSupertypeChainIterator

@testset "Type chain iterators" begin

@testset "SupertypeChainIterator" begin
    @test collect(SupertypeChainIterator(String)) == Type[String, AbstractString, Any]
    @test collect(SupertypeChainIterator(AbstractString)) == Type[AbstractString, Any]
    @test collect(SupertypeChainIterator(Any)) == Type[Any]

    @test collect(SupertypeChainIterator(Int)) == Type[Int, Signed, Integer, Real, Number, Any]
    @test collect(SupertypeChainIterator(Integer)) == Type[Integer, Real, Number, Any]

    @test collect(SupertypeChainIterator(Vector{String})) == 
        Type[Vector{String}, DenseArray{String,1}, AbstractArray{String,1}, Any]
    @test collect(SupertypeChainIterator(DenseArray{String,1})) == 
        Type[DenseArray{String,1}, AbstractArray{String,1}, Any]
end

@testset "SubSupertypeChainIterator" begin
    @test collect(SubSupertypeChainIterator(String)) == Type[]
    @test collect(SubSupertypeChainIterator(AbstractString)) == Type[]
    @test collect(SubSupertypeChainIterator(Any)) == Type[]

    @test collect(SubSupertypeChainIterator(Int)) == Type[]
    @test collect(SubSupertypeChainIterator(Integer)) == Type[]

    @test collect(SubSupertypeChainIterator(Vector{String})) == 
        Type[Vector{String}, Vector{AbstractString}, Vector{Any}]
    @test collect(SubSupertypeChainIterator(Vector{AbstractString})) == 
        Type[Vector{AbstractString}, Vector{Any}]
end

end