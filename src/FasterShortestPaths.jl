module FasterShortestPaths

using DataStructures
using Graphs
using SimpleWeightedGraphs

include("graph.jl")
include("astar.jl")

export AstarQueueStorage, AstarHeapStorage, custom_astar!

end # module FasterShortestPaths
