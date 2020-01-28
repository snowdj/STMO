#=
Created on Thurday 02 January 2019
Last update: Tuesday 28 January 2020

@author: Michiel Stock
michielfmstock@gmail.com

General stuff.
=#

# COLORS
# ------

myblue = "#304da5"
mygreen = "#2a9d8f"
myyellow = "#e9c46a"
myorange = "#f4a261"
myred = "#e76f51"
myblack = "#50514F"

mycolors = [myblue, myred, mygreen, myorange, myyellow]


# TRACING
# -------


abstract type Tracker end

struct NoTrack <: Tracker
end

notrack = NoTrack()

struct PathTrack{T<:Any} <: Tracker
    xsteps::Array{T,1}
    PathTrack(x::T) where {T} = new{T}(copy(T[x]))
end

trace(::NoTrack, x) = nothing
trace(tracker::PathTrack, x) = push!(tracker.xsteps, copy(x))

nsteps(tracker::PathTrack) = length(tracker.xsteps) - 1

function getx(tracker::PathTrack)
    n = length(tracker.xsteps)
    return [x[1] for x in tracker.xsteps], [x[2] for x in tracker.xsteps]
end

# PLOTS
# -----

path(tracker::PathTrack; kwargs...) = plot(getx(tracker)...; color=mygreen, lw=2, kwargs...)
path!(tracker::PathTrack; kwargs...) = plot!(getx(tracker)...; color=myorange, lw=2, kwargs...)

plotobj(f::Function, tracker::PathTrack; kwargs...) = plot(0:nsteps(tracker), f.(tracker.xsteps),
                                                 lw=2, color=myorange, xlabel="iteration"; kwargs...)
plotobj!(f::Function, tracker::PathTrack; kwargs...) = plot!(0:nsteps(tracker), f.(tracker.xsteps);
                                                lw=2,color=mygreen, kwargs...)

using Colors
colorscatter(colors; kwargs...) = scatter(red.(colors), green.(colors), blue.(colors),
                        xlabel="red", ylabel="green", zlabel="blue", color=colors, label="")


# FUNCTIONS
# --------
"""
Compute Euclidean distance between two vectors.
"""
dist(x::AbstractVector, y::AbstractVector) = sqrt(sum((x .- y).^2))
"""
Compute Euclidean distance matrix between two matrices.
"""
dist(X::AbstractMatrix, Y::AbstractMatrix) = [dist(X[i,:], Y[j,:]) for i in 1:size(X,1), j in 1:size(Y,1)]
"""
Compute Euclidean distance matrix.
"""
dist(X::AbstractMatrix) = dist(X::AbstractMatrix, X::AbstractMatrix)


# GRAPHS
# -----

# special types for graphs
EdgeList{T} = Array{Tuple{T,T},1}
WeightedEdgeList{R,T} = Array{Tuple{R,T,T},1}
Vertices{T} = Array{T,1}
AdjList{R,T} = Dict{T, Array{Tuple{R,T},1}}

function edges2adjlist(edges::WeightedEdgeList{R,T}; double=true)  where {R<:Real,T}
    adjlist = AdjList{R,T}()
    for (w, i, j) in edges
        if !haskey(adjlist, i); adjlist[i] = [] end
        if !haskey(adjlist, j); adjlist[j] = [] end
        push!(adjlist[i], (w, j))
        double && push!(adjlist[j], (w, i))
    end
    return adjlist
end

function adjlist2edges(adjlist::AdjList{R,T}) where {R<:Real, T}
    edges = WeightedEdgeList{R,T}
    for (v, neighbors) in adjlist
        for (w, n) in neighbors
            push!(edges, (w, v, n))
        end
    end
    return edges
end
