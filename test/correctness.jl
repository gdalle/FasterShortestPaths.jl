using FasterShortestPaths
using Graphs
using SimpleWeightedGraphs
using SparseArrays
using Test

@testset "Dijkstra" begin
    for k in 1:10
        A = sprand(100, 100, k / 20)
        g = SimpleWeightedDiGraph(A)
        dep = 1
        for storage in (DijkstraHeapStorage(g), DijkstraQueueStorage(g))
            custom_dijkstra!(storage, g, dep)
            dists_ref = Graphs.dijkstra_shortest_paths(g, dep).dists
            @test storage.dists ≈ dists_ref
        end
    end
end

@testset "A*" begin
    for k in 1:10
        A = sprand(100, 100, k / 20)
        g = SimpleWeightedDiGraph(A)
        dep, arr = 1, nv(g)
        heuristic = zeros(nv(g))
        for storage in (AstarHeapStorage(g), AstarQueueStorage(g))
            path = custom_astar!(storage, g, dep, arr, heuristic)
            result_ref = Graphs.a_star(g, dep, arr)
            path_ref = vcat(Graphs.src.(result_ref), arr)
            @test path == path_ref
        end
    end
end
