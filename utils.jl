"""
open map file and return list of tuples.
FIRST digit of vertices coordinates will always be in the 14th position
LAST digit of vertices coordinates will always be in the second to last position
But amount of digits in between these two varies
"""
function readMap(mapFile)
  p = 1
  open(mapFile) do map
    fileContent = readlines(map)
    numberLines = 5000
    plane = Array{Array{Tuple{Vararg{Float64, 3}}}}(undef, numberLines)
    for line in 1:length(fileContent)
      line % 10000 == 0 && println("line $line")
      if length(fileContent[line]) > 8 && fileContent[line][5:9] == "plane"
        # Example of line of interest: "plane" "(5167 710 2720) (5167 710 1808) (5167 702 1808)"
        words = split(fileContent[line])
        if p <= numberLines
          plane[p] = [
            # Coordinates of first vertex
            (parse(Float64, words[2][3:end]), parse(Float64, words[3]), parse(Float64, words[4][1:end-1]))
            # Coordinates of second vertex
            (parse(Float64, words[5][2:end]), parse(Float64, words[6]), parse(Float64, words[7][1:end-1]))
            # Coordinates of third vertex
            (parse(Float64, words[8][2:end]), parse(Float64, words[9]), parse(Float64, words[10][1:end-2]))
          ]
          p += 1
        else
          plane = vcat(
            plane,
            [
              # Coordinates of first vertex
              (parse(Float64, words[2][3:end]), parse(Float64, words[3]), parse(Float64, words[4][1:end-1]))
              # Coordinates of second vertex
              (parse(Float64, words[5][2:end]), parse(Float64, words[6]), parse(Float64, words[7][1:end-1]))
              # Coordinates of third vertex
              (parse(Float64, words[8][2:end]), parse(Float64, words[9]), parse(Float64, words[10][1:end-2]))
            ]
          )
          p += 1
        end
      end
    end
  end
  plane = plane[1:p-1]
  # each 6 planes is used to define a hexahedron. reshape vector into 6 x n matrix
  planeMat = Array{Any}(undef, (6, convert(Int, (p-1)/6)))
  [planeMat[:,m] .= plane[6*m-5:6*m] for m in 1:size(planeMat,2)]
  return plane, planeMat
end


"""
Groups of 6 planes are used to define hexahedrons.
Each plane is defined by 3 points: 6*3 = 18 points.
But some points are repeated.
They are reordered according to the vtk convention.
And finally output a list of these hexahedrons.
"""
function hexFromPlanes(planesMat)
  points = Array{Any}(undef, (8,size(planesMat,2)) ) # each column stores unique points from a hexahedron
  base = Array{Any}(undef, (4,size(planesMat,2)) ) # each column stores points with minimum z coordinate
  grid = CartesianGrid(10,10,10)
  hexas2 = view(grid, 1:10) |> collect
  hexas = Array{typeof(hexas2[1])}(undef, size(planesMat,2))
  # planeMat[i,j] -> vector -> 3 tuples -> 3 floats/tuple
  for hex in 1:size(planesMat,2)
    # extract the 8 points needed for each hexahedron
    points[:,hex] .= Meshes.Point.(unique(collect(Iterators.flatten(planesMat[:,hex]))))
    # z coordinates of extracted points
    # zCoords = [points[i][3] for i in 1:length(points)]
    # points with lowest z coordinate (length = 4)
    # base = points[findall(x->x==minimum(zCoords), points)]
    # build hexahedron struct
    hexas[hex] = Meshes.Hexahedron((points[:,hex]...))
  end
  return points, hexas
end

"""
transforms Meshes.point() definition of hexahedrons to "cubes" in SolidModeling.jl
"""
function pointsToCubes(points)
  center = [zeros(3) for _ in 1:size(points, 2)]
  edges = deepcopy(center)
  for (ppID, planePoints) in points |> eachcol |> enumerate
    coords = [(plaPoi.coords.x.val, plaPoi.coords.y.val, plaPoi.coords.z.val) for plaPoi in planePoints]
    center[ppID] .= [mean(getindex.(coords, i)) for i in 1:3]
    # edges[ppID] = abs.([maximum(x)-minimum(x), maximum(y)-minimum(y), maximum(z)-minimum(z)])
    edges[ppID] .= [getindex.(coords, i) |> extrema |> collect |> diff |> only |> abs for i in 1:3]
  end
  # cube(center::Vector{Float64}, lx::Float64, ly::Float64, lz::Float64)::Solid
  return [SolidModeling.cube(center[hex], edges[hex]...) for hex in keys(center)]
end

struct BSPdata
  ID::Int
  node::Any
end

"""Obtain binary space partition (BSP) from SolidModeling.node recursive structure"""
function BSPfromNodes(nodes)
  g = SimpleGraph(1)
  nodeID = 1
  # IDs = []
  BSP = Array{Any}(undef, 1)
  function recGraph(nd, ndID)
    nodeID += 1
    if nd.front !== nothing
      # IDs = vcat(IDs, nodeID)
      BSP = vcat(BSP, BSPdata(nodeID, nd))
      add_vertex!(g)
      add_edge!(g, nodeID, ndID)
      recGraph(nd.front, nodeID)
    end
    if nd.back !== nothing
      # IDs = vcat(IDs, nodeID)
      BSP = vcat(BSP, BSPdata(nodeID, nd))
      add_vertex!(g)
      add_edge!(g, nodeID, ndID)
      recGraph(nd.back, nodeID)
    end
  end
  recGraph(nodes, nodeID)
  # [println(i, "   ", g.fadjlist[i]) for i in 1:6]
  # [println(i, "   ", IDs[i]) for i in 1:6]
  return g, BSP
end