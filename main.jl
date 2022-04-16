# Began coding 09/feb/2022
# Author: Lucas Pereira, SP, Brazil

using Graphs, Plots, GraphRecipes
import Meshes, MeshViz
include("./utils.jl")
include("./SolidModeling.jl/src/SolidModeling.jl")

#
  # p1 = Meshes.Point(-128, 0, 0)
  # p2 = Meshes.Point(-128, 32, 0)
  # p3 = Meshes.Point(128, 32, 0)
  # p4 = Meshes.Point(128, 0, 0)
  # p5 = Meshes.Point(-128, 0, 128)
  # p6 = Meshes.Point(-128, 32, 128)
  # p7 = Meshes.Point(128, 32, 128)
  # p8 = Meshes.Point(128, 0, 128)

  # points1 = [p1, p2, p3, p4, p5, p6, p7, p8]

  # hexa = Meshes.Hexahedron(points1...)

  # display(MeshViz.viz(hexa))
  # Meshes.measure(hexa)

#


# List of planes. Each plane is defined by three tuples{Float,3}
# Each tuple contains the coordinates of a vertex that defines the respective plane
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
@time BSP = BSPfromNodes(nodes)

@time for i in 1:20000
  s = rand(1:12_000)
  t = rand(1:12_000)
  print(s, "   ", t, " ")
  @time path = a_star(BSP, s, t)
end
# Define hexahedron with 8 points obtained
# display(MeshViz.viz(hexas[1]))