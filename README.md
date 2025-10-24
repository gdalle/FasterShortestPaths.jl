# FasterShortestPaths.jl

Dijkstra + A* implementation for weighted graphs designed to be faster than that of Graphs.jl.

## Features

- type-stability
- reusable storage space
- better memory locality
- option to use a heap instead of a queue (see [this paper](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf) for why it matters)

## Example use

```julia
julia> using Chairmarks, FasterShortestPaths, Graphs, SimpleWeightedGraphs, SparseArrays

julia> g = SimpleWeightedDiGraph(sprand(1000, 1000, 0.01))
{1000, 10033} directed simple Int64 graph with Float64 weights

julia> @b (g, 1) dijkstra_shortest_paths(_...)  # from Graphs.jl
286.041 μs (50 allocs: 148.125 KiB)

julia> @b (DijkstraQueueStorage(g), g, 1) custom_dijkstra!(_...) evals = 1
148.063 μs (2.80 allocs: 10.652 KiB)

julia> @b (DijkstraHeapStorage(g), g, 1) custom_dijkstra!(_...) evals = 1
75.996 μs (0.80 allocs: 4.397 KiB)
```
