using Test

@testset verbose = true "FasterShortestPaths" begin
    @testset "Correctness" begin
        include("correctness.jl")
    end
    @testset "Type stability" begin
        include("type_stability.jl")
    end
end
