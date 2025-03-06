with_theme(theme_dark()) do
  fig = Figure(; size = (1700, 700))
  lscene = LScene(fig[1, 1]; show_axis=false)
  m = 0
  hObs = Observable(Rect3d.(hexas))
  for (id, hex) in enumerate(hexas)
    # id in [346, 352, 64, 66, 63, 350, 69, 351, 349] && continue
    m = mesh!.(lscene, hObs[]; alpha = 0.1)
  end
  obs = Observable{Any}(0.0)
  on(events(lscene).mousebutton, priority = 2) do event
    if event.button == Mouse.left && event.action == Mouse.press
      if Keyboard.left_shift in events(fig).keyboardstate # print id
        plt = pick(m)[1]
        findfirst(==(plt.deregister_callbacks[2].observable[]), hexas) |> println
      elseif Keyboard.left_control in events(fig).keyboardstate # remove hexahedron
        plt = pick(m)[1]
        id = findfirst(==(plt.deregister_callbacks[2].observable[]), hexas) |> println
        deleteat!(hObs[], id)
        notify(hObs)
        # return Consume(true)
      end
    end
  end
  fig
end

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
