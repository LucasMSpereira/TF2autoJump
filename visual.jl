begin
  # hex = hexas[293]
  fig = Figure()
  ax = Axis3(fig[1, 1])
  # viz(hex, showsegments = true, showpoints = true)
  for hex in hexas
    coords = [[vert.coords.x.val, vert.coords.y.val, vert.coords.z.val] for vert in hex.vertices]
    coordMat = hcat(coords...)
    ranges = extrema(coordMat; dims = 2) .|> collect .|> diff .|> only .|> abs |> vec
    origin = minimum(coordMat; dims = 2) |> vec
    rec = Rect3d(origin, ranges)
    m = mesh!(ax, rec)
    wireframe!(ax, m[1], color = :black)
  end
  fig
end
k = 135
@time display(Meshes.viz(hexas[1:end - k]; color = 1:length(hexas) - k))

fig = Figure(resolution=(900,900));
extraFrames = 7 # odd integer. how many frames per topology
deltaFrames = (extraFrames-1) ÷ 2
topos = zeros(problem_size...,extraFrames*length(tObj.trace))
for g in keys(tObj.trace)
  @show (g-1)*extraFrames+1 : (2*deltaFrames+(g-1)*extraFrames)+1
  topos[:,:, (g-1)*extraFrames+1 : (2*deltaFrames+(g-1)*extraFrames+1)] .= quad(problem_size..., tObj.trace[g][1])'
end
fig, ax, hm = heatmap(1:problem_size[1], 1:problem_size[2], topos[:,:,1])

record(fig, "TOBS.mp4", 1:size(topos,3)) do i
  hm[3] = topos[:,:,i] # update data
end

# k = 135
# fig = Figure(resolution=(900,900));
# frames = [MeshViz.viz(hexas[1:p]) for p in 1:length(hexas)-k];
# record(fig, "beef.mp4", 1:length(hexas)-k) do i
#   x = frames[i]; # update data
# end
# b = MeshViz.viz(hexas[1]);