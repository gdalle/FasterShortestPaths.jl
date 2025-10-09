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

struct OptimizedAstarStorage{U,W,H<:BinaryHeap}
    parents::Vector{U}
    dists::Vector{W}
    heap::H
end

function OptimizedAstarStorage(g::AbstractGraph, distmx::AbstractMatrix)
    U, W = eltype(g), eltype(distmx)
    n = nv(g)
    parents = zeros(U, n)
    dists = fill(typemax(W), n)
    heap = BinaryHeap(Base.By(last), Pair{U,Tuple{W,W}}[])
    sizehint!(heap, n)
    return OptimizedAstarStorage(parents, dists, heap)
end

function reset!(storage::OptimizedAstarStorage{U,W}) where {W<:Number,U<:Integer}
    (; heap, parents, dists) = storage
    empty!(heap.valtree)
    fill!(parents, zero(U))
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
    g::AbstractGraph{U},
    storage,
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

n_nodes = 1000
random_graph = erdos_renyi(n_nodes, 0.1; is_directed=true)
W = Float64.(rand(1:n_nodes, nv(random_graph), nv(random_graph)))
# W = rand(1:n_nodes, nv(random_graph), nv(random_graph))
src, dst = 1, n_nodes

storage = AstarStorage(random_graph, W)
storage_optimized = OptimizedAstarStorage(random_graph, W)

function minimal_a_star(n_iter::Int)
    for _ in 1:n_iter
        a_star(random_graph, src, dst, W)
    end
end

function minimal_custom_a_star(n_iter::Int)
    for _ in 1:n_iter
        custom_astar!(random_graph, storage, src, dst, W)
    end
end

minimal_a_star(1)
@profview minimal_a_star(1000)

minimal_custom_a_star(1)
@profview minimal_custom_a_star(1000)

@btime a_star(random_graph, src, dst, W);
@btime custom_astar!(random_graph, storage, src, dst, W);
@btime custom_astar!(random_graph, storage_optimized, src, dst, W);