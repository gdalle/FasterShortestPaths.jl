function DijkstraHeapStorage(g::CompatibleGraph)
    W = eltype(weights(g))
    parents = zeros(Int, nv(g))
    dists = fill(typemax(W), nv(g))
    heap = BinaryHeap(Base.By(last), Pair{Int, W}[])
    return HeapStorage(parents, dists, heap)
end

function DijkstraQueueStorage(g::CompatibleGraph)
    W = eltype(weights(g))
    parents = zeros(Int, nv(g))
    dists = fill(typemax(W), nv(g))
    queue = PriorityQueue{Int, W}(Base.By(last))
    sizehint!(queue, nv(g))
    return QueueStorage(parents, dists, queue)
end

function custom_dijkstra!(
        storage::HeapStorage{W},
        g::CompatibleGraph{Int, W},
        dep::Int,
    ) where {W}
    reset!(storage)
    (; heap, parents, dists) = storage
    # Add source
    dists[dep] = zero(W)
    push!(heap, dep => zero(W))
    # Main loop
    while !isempty(heap)
        u, cu = pop!(heap)
        if cu <= dists[u]
            dists[u] = cu
            for (v, w_uv) in neighbors_and_weights(g, u)
                w_uv == typemax(W) && continue
                cv = dists[v]
                if cu + w_uv < cv
                    parents[v] = u
                    dists[v] = cu + w_uv
                    # insert
                    push!(heap, v => cu + w_uv)
                end
            end
        end
    end
    return
end

function custom_dijkstra!(
        storage::QueueStorage{W},
        g::CompatibleGraph{Int, W},
        dep::Int,
    ) where {W}
    reset!(storage)
    (; queue, parents, dists) = storage
    # Add source
    dists[dep] = zero(W)
    push!(queue, dep => zero(W))
    # Main loop
    while !isempty(queue)
        u, cu = popfirst!(queue)
        dists[u] = cu
        for (v, w_uv) in neighbors_and_weights(g, u)
            w_uv == typemax(W) && continue
            cv = dists[v]
            if cu + w_uv < cv
                parents[v] = u
                dists[v] = cu + w_uv
                if cv == typemax(W)
                    # insert
                    push!(queue, v => cu + w_uv)
                else
                    # decrease key
                    queue[v] = cu + w_uv
                end
            end
        end
    end
    return
end
