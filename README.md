# FasterShortestPaths.jl

A* implementation for weighted graphs designed to be faster than that of Graphs.jl thanks to

- type-stability
- reusable storage space
- better memory locality
- option to use a heap instead of a queue (see [this paper](https://www3.cs.stonybrook.edu/~rezaul/papers/TR-07-54.pdf) for why it matters)