const CompatibleGraph{T, W} = Union{SimpleWeightedGraph{T, W}, SimpleWeightedDiGraph{T, W}}

function neighbors_and_weights(g::CompatibleGraph, u::Integer)
    w = g.weights
    interval = w.colptr[u]:(w.colptr[u + 1] - 1)
    return zip(view(w.rowval, interval), view(w.nzval, interval))
end
