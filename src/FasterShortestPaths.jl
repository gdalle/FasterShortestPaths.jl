module FasterShortestPaths

using DataStructures
using Graphs
using SimpleWeightedGraphs

include("graph.jl")
include("storage.jl")
include("dijkstra.jl")
include("astar.jl")

export DijkstraQueueStorage, DijkstraHeapStorage, custom_dijkstra!
export AstarQueueStorage, AstarHeapStorage, custom_astar!

end # module FasterShortestPaths
