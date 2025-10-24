# notations taken from https://en.wikipedia.org/wiki/A*_search_algorithm

struct AstarNodeCost{W}
    g::W
    h::W
end

@inline cost_estimate(c::AstarNodeCost) = c.g + c.h
@inline cost_estimate(c::Pair{Int, AstarNodeCost{W}}) where {W} = cost_estimate(last(c))

function AstarHeapStorage(g::CompatibleGraph)
    W = eltype(weights(g))
    parents = zeros(Int, nv(g))
    dists = fill(typemax(W), nv(g))
    heap = BinaryHeap(Base.By(cost_estimate), Pair{Int, AstarNodeCost{W}}[])
    return HeapStorage(parents, dists, heap)
end

function AstarQueueStorage(g::CompatibleGraph)
    W = eltype(weights(g))
    parents = zeros(Int, nv(g))
    dists = fill(typemax(W), nv(g))
    queue = PriorityQueue{Int, AstarNodeCost{W}}(Base.By(cost_estimate))
    sizehint!(queue, nv(g))
    return QueueStorage(parents, dists, queue)
end

function custom_astar!(
        storage::HeapStorage{W},
        g::CompatibleGraph{Int, W},
        dep::Int,
        arr::Int,
        heuristic::Vector{W} = fill(zero(W), nv(g)),
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
    return
end

function custom_astar!(
        storage::QueueStorage{W},
        g::CompatibleGraph{Int, W},
        dep::Int,
        arr::Int,
        heuristic::Vector{W} = fill(zero(W), nv(g)),
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
    return
end
