# notations taken from https://en.wikipedia.org/wiki/A*_search_algorithm

struct AstarHeapStorage{W<:Real,H<:BinaryHeap}
    parents::Vector{Int}
    dists::Vector{W}
    heap::H
end

struct AstarQueueStorage{W<:Real,Q<:PriorityQueue}
    parents::Vector{Int}
    dists::Vector{W}
    queue::Q
end

struct AstarNodeCost{W}
    g::W
    h::W
end

@inline cost_estimate(c::AstarNodeCost) = c.g + c.h
@inline cost_estimate(c::Pair{Int,AstarNodeCost{W}}) where {W} = cost_estimate(last(c))

function AstarHeapStorage(g::SimpleWeightedDiGraph)
    W = eltype(weights(g))
    parents = zeros(Int, nv(g))
    dists = fill(typemax(W), nv(g))
    heap = BinaryHeap(Base.By(cost_estimate), Pair{Int,AstarNodeCost{W}}[])
    return AstarHeapStorage(parents, dists, heap)
end

function AstarQueueStorage(g::SimpleWeightedDiGraph)
    W = eltype(weights(g))
    parents = zeros(Int, nv(g))
    dists = fill(typemax(W), nv(g))
    queue = PriorityQueue{Int,AstarNodeCost{W}}(Base.By(cost_estimate))
    return AstarQueueStorage(parents, dists, queue)
end

function reset!(storage::AstarHeapStorage{W}) where {W}
    (; heap, parents, dists) = storage
    empty!(heap)
    fill!(parents, 0)
    fill!(dists, typemax(W))
    return nothing
end

function reset!(storage::AstarQueueStorage{W}) where {W}
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

function custom_astar!(
    storage::AstarHeapStorage{W},
    g::SimpleWeightedDiGraph{Int,W},
    dep::Int,
    arr::Int,
    heuristic::Vector{W}=fill(zero(W), nv(g)),
) where {W}
    reset!(storage)
    (; heap, parents, dists) = storage
    # Add source
    dists[dep] = zero(W)
    cdep = AstarNodeCost(zero(W), heuristic[dep])
    push!(heap, dep => cdep)
    # Main loop
    while !isempty(heap)
        u, cu = pop!(heap)
        gu = cu.g
        if u == arr
            path = reconstruct_path(storage, dep, arr)
            return path
        elseif gu <= dists[u]
            dists[u] = gu
            for (v, w_uv) in neighbors_and_weights(g, u)
                w_uv == typemax(W) && continue
                hv = heuristic[v]
                hv == typemax(W) && continue
                gv = dists[v]
                if gu + w_uv < gv
                    parents[v] = u
                    dists[v] = gu + w_uv
                    new_cv = AstarNodeCost(gu + w_uv, hv)
                    # insert
                    push!(heap, v => new_cv)
                end
            end
        end
    end
end

function custom_astar!(
    storage::AstarQueueStorage{W},
    g::SimpleWeightedDiGraph{Int,W},
    dep::Int,
    arr::Int,
    heuristic::Vector{W}=fill(zero(W), nv(g)),
) where {W}
    reset!(storage)
    (; queue, parents, dists) = storage
    # Add source
    dists[dep] = zero(W)
    cdep = AstarNodeCost(zero(W), heuristic[dep])
    push!(queue, dep => cdep)
    # Main loop
    while !isempty(queue)
        u, cu = popfirst!(queue)
        gu = cu.g
        if u == arr
            path = reconstruct_path(storage, dep, arr)
            return path
        else
            dists[u] = gu
            for (v, w_uv) in neighbors_and_weights(g, u)
                w_uv == typemax(W) && continue
                hv = heuristic[v]
                hv == typemax(W) && continue
                gv = dists[v]
                if gu + w_uv < gv
                    parents[v] = u
                    dists[v] = gu + w_uv
                    new_cv = AstarNodeCost(gu + w_uv, hv)
                    if gv == typemax(W)
                        # insert
                        push!(queue, v => new_cv)
                    else
                        # decrease key
                        queue[v] = new_cv
                    end
                end
            end
        end
    end
end
