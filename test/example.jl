using Chairmarks, FasterShortestPaths, Graphs, SimpleWeightedGraphs, SparseArrays

g = SimpleWeightedDiGraph(sprand(1000, 1000, 0.01))
@b (g, 1) dijkstra_shortest_paths(_...)  # from Graphs.jl
@b (DijkstraQueueStorage(g), g, 1) custom_dijkstra!(_...) evals = 10
@b (DijkstraHeapStorage(g), g, 1) custom_dijkstra!(_...) evals = 10
