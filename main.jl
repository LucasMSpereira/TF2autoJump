# Starting coding 09/feb/2022
# Author: Lucas Pereira, SP, Brazil

import Meshes, MeshViz, GLMakie

p1 = Meshes.Point(-128, 32, 128)
p2 = Meshes.Point(128, 32, 128)
p3 = Meshes.Point(128, 0, 128)
p4 = Meshes.Point(-128, 0, 0)
p5 = Meshes.Point(128, 0, 0)
p6 = Meshes.Point(128, 32, 0)
p7 = Meshes.Point(-128, 0, 128)
p8 = Meshes.Point(-128, 32, 0)

hexa = Meshes.Hexahedron(p1, p2, p3, p4, p5, p6, p7, p8)

display(MeshViz.viz(hexa))