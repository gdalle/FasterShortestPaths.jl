using BenchmarkTools
using DataStructures
using Graphs
using Random

struct AstarStorage{U,W,H<:BinaryHeap}
    parents::Dict{U,U}
    dists::Dict{U,W}
    heap::H
end

function AstarStorage(g::AbstractGraph, distmx::AbstractMatrix)
    U, W = eltype(g), eltype(distmx)
    parents = Dict{U,U}()
    dists = Dict{U,W}()
    heap = BinaryHeap(Base.By(last), Pair{U,Tuple{W,W}}[])
    sizehint!(heap, nv(g))
    return AstarStorage(parents, dists, heap)
end

function reset!(storage::AstarStorage{U,W}) where {W<:Number,U<:Integer}
    (; heap, parents, dists) = storage
    empty!(heap.valtree)  # internal, will be released in DataStructures v0.19
    empty!(parents)
    empty!(dists)
    return nothing
end

function reconstruct_path(
    storage::AstarStorage, dep::Integer, arr::Integer,
)
    (; parents) = storage
    path = [arr]
    v = arr
    while haskey(parents, (v))
        v = parents[v]
        push!(path, v)
    end
    @assert last(path) == dep
    return reverse(path)
end

function custom_astar!(
    g::AbstractGraph{U},
    storage::AstarStorage{U,W},
    dep::U,
    arr::U,
    distmx::AbstractMatrix{W};
    heuristic::AbstractVector{W}=fill(zero(W), nv(g)),
) where {W<:Number} where {U<:Integer}

    reset!(storage)
    (; heap, parents, dists) = storage
    # Add source
    dists[dep] = zero(W)
    push!(heap, dep => (zero(W), heuristic[dep]))
    # Main loop
    while !isempty(heap)
        u, (du, _) = pop!(heap)
        if u == arr
            path = reconstruct_path(storage, dep, arr)
            return path
        elseif du <= dists[u]
            dists[u] = du
            for v in outneighbors(g, u)
                w_uv = distmx[u, v]
                if w_uv == typemax(W)  # no edge
                    continue
                end
                heuristic[v] == typemax(W) && continue
                dv = get(dists, v, typemax(W))
                if du + w_uv < dv
                    parents[v] = u
                    dists[v] = du + w_uv
                    hv = du + w_uv + heuristic[v]
                    push!(heap, v => (du + w_uv, hv))
                end
            end
        end
    end
end

## make sure the two implementations give the same result
function test_a_star()
    for random_seed in 1:5
        Random.seed!(random_seed)
        n_nodes = 50
        random_graph = erdos_renyi(n_nodes, 0.3)
        W = rand(1:n_nodes, nv(random_graph), nv(random_graph))
        src, dst = 1, n_nodes
        edges1 = a_star(random_graph, src, dst, W)
        path1 = [src]
        for e in edges1
            push!(path1, e.dst)
        end
        @show path1
        println("Path found by Graphs.jl a_star: $path1")

        storage = AstarStorage(random_graph, W)
        path2 = custom_astar!(random_graph, storage, src, dst, W)
        @show path2

        @assert path1 == path2
    end
end

test_a_star()
## benchmark time and memory
n_nodes = 500
random_graph = erdos_renyi(n_nodes, 0.8)
W = rand(1:n_nodes, nv(random_graph), nv(random_graph))
src, dst = 1, n_nodes
storage = AstarStorage(random_graph, W)

function minimal_a_star(n_iter::Int)
    for i in 1:n_iter
        edges = a_star(random_graph, src, dst, W)
    end
end

function minimal_custom_a_star(n_iter::Int)
    storage = AstarStorage(random_graph, W)
    for i in 1:n_iter
        edges = custom_astar!(random_graph, storage, src, dst, W)
    end
end

@profview minimal_a_star(1)
@profview minimal_a_star(500)
@btime a_star(random_graph, src, dst, W)

@profview minimal_custom_a_star(1)
@profview minimal_custom_a_star(500)
@btime custom_astar!(random_graph, storage, src, dst, W)