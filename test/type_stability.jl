using FasterShortestPaths
using Graphs
using SimpleWeightedGraphs
using SparseArrays
using Test
using JET

@testset "Dijkstra" begin
    g = SimpleWeightedGraph(complete_graph(10))
    storage = DijkstraHeapStorage(g)
    @test_call custom_dijkstra!(storage, g, 1)
    @test_opt custom_dijkstra!(storage, g, 1)
    storage = DijkstraQueueStorage(g)
    @test_call custom_dijkstra!(storage, g, 1)
    @test_opt custom_dijkstra!(storage, g, 1)
end

@testset "A*" begin
    g = SimpleWeightedGraph(complete_graph(10))
    storage = AstarHeapStorage(g)
    @test_call custom_astar!(storage, g, 1, 2, zeros(10))
    @test_opt custom_astar!(storage, g, 1, 2, zeros(10))
    storage = AstarQueueStorage(g)
    @test_call custom_astar!(storage, g, 1, 2, zeros(10))
    @test_opt custom_astar!(storage, g, 1, 2, zeros(10))
end
