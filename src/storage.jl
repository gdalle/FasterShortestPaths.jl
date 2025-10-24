struct HeapStorage{W <: Real, H <: BinaryHeap}
    parents::Vector{Int}
    dists::Vector{W}
    heap::H
end

struct QueueStorage{W <: Real, Q <: PriorityQueue}
    parents::Vector{Int}
    dists::Vector{W}
    queue::Q
end

function reset!(storage::HeapStorage{W}) where {W}
    (; heap, parents, dists) = storage
    empty!(heap)
    fill!(parents, 0)
    fill!(dists, typemax(W))
    return nothing
end

function reset!(storage::QueueStorage{W}) where {W}
    (; queue, parents, dists) = storage
    empty!(queue)
    fill!(parents, 0)
    fill!(dists, typemax(W))
    return nothing
end

function reconstruct_path(storage, dep::Integer, arr::Integer)
    (; parents) = storage
    path = Int[]
    v = arr
    while v != dep
        push!(path, v)
        v = parents[v]
        v == 0 && error("Invalid path reconstruction")
    end
    push!(path, dep)
    return reverse(path)
end
