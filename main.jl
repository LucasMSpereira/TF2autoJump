# Began coding 09/feb/2022
# Author: Lucas Pereira, SP, Brazil

using Graphs, Plots, GraphRecipes
import Meshes, MeshViz
include("./utils.jl")
include("./SolidModeling.jl/src/SolidModeling.jl")

# planes: List of planes. Each plane is defined by three tuples{Float,3}
  # Each tuple contains the coordinates of a vertex that defines the respective plane
# planesMat: 6 x number_of_hexahedrons matrix. Each column contains the 6 planes used to define each hexahedron
@time planes, planesMat = readMap("./vmf/jump_beef_d.vmf")

# List of hexahedrons 
@time points, hexas = hexFromPlanes(planesMat)

# Get list of SolidModeling.cubes to build BSP tree
@time cubes = pointsToCubes(points)

# Transform list of solids/polyhedra (typeof(cubes[i]) = SolidModeling.cube)
# into list of SolidModeling.Polygon
polygons = SolidModeling.toPolygons(cubes[1])
[global polygons = vcat(polygons, SolidModeling.toPolygons(cubes[f])) for f in 2:length(cubes)]

# Obtain node structure from recursive function SolidModeling.build()
@time nodes = SolidModeling.build(
  SolidModeling.Node(nothing, nothing, nothing, Array{Polygon,1}()),
  polygons
);

# Build binary space partition (BSP) graph from node structure
@time graph, BSPgeom = BSPfromNodes(nodes)

@time path = a_star(graph, rand(1:length(graph.fadjlist),2)...);

k = 135
@time display(MeshViz.viz(hexas[1:end-k]; color = 1:length(hexas)-k))