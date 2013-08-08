local plot_size = 400
local input = {}
local weights = {0, 0, 0}
local learning_rate = 0.01
local converged = false
local average_error = 0
local error_thresold = 1e-5
local iteration_count = 0
local graph = {width = 200, height = 700, data = {{},{},{}}, title = {"w1", "w2", "w3"}}

function love.load(arg)
  local path

  if arg[3] then 
    path = arg[3]
  elseif arg[2] then
    path = arg[2]
  else
    print("Missing input data.")
    love.event.push("quit")
    return
  end

  local file = io.open(path, "r")
  
  if not file then
    print("Missing input data.")
    love.event.push("quit")
    return
  end    
  
  local size = tonumber(file:read("*line"))
  local count = 0
  
  for s in file:lines() do
    count = count + 1
  local valid = true
  local item = {}
    for token in string.gmatch(s, "[^%s]+") do
    if token then
        table.insert(item, tonumber(token))
    else
      valid = false
    end
    end
  
  if valid and #item == 3 then
    table.insert(input, item)
  end
  
  if count == size then
    break
  end
  end    

  file:close()
end  

function love.update(dt)
  if converged then return end
  
  iteration_count = iteration_count + 1

  local error_sum = 0
  
  for _, v in pairs(input) do
    local x = v[1]
  local y = v[2]
  local desired_output = v[3]
    local current_output = perceptronOutput(x, y)
  
  local error = learning_rate * (desired_output - current_output)

  updateWeight(1, error, x)
  updateWeight(2, error, y)
  updateWeight(3, error, 1)
  
  error_sum = error_sum + error
  end
  
  average_error = error_sum / #input

  if math.abs(average_error) < error_thresold then
    converged = true
  end
end

function updateWeight(w, err, value)
  weights[w] = weights[w] + err * value
  updateGraph(w, weights[w])
  
end 

function updateGraph(w, value)
  table.insert(graph.data[w], value)
end

function perceptronOutput(x, y)
  return x * weights[1] + y * weights[2] + weights[3]
end

function love.draw()
  love.graphics.push()
  love.graphics.translate(50, 350)
  
  drawAxis()
  drawInput()
  drawPerceptron()
  
  love.graphics.pop()  
  
  drawGraphs()
  drawInfo()
end

function drawAxis()
  love.graphics.setColor(120, 120, 120, 255)
  love.graphics.line(0, 0, 0, plot_size)
  love.graphics.line(0, plot_size, plot_size, plot_size)
end

function drawGraphs()  
  local top = 50
  local left = plot_size + 50 + 25
  local margin = 10
  
  drawGraph(1, left, top)
  
  left = left + graph.width + margin
  drawGraph(2, left, top)
  
  left = left + graph.width + margin
  drawGraph(3, left, top)
  
  love.graphics.line(plot_size + 50 + 10, top + graph.height / 2, left + graph.width + 10, top + graph.height / 2)
end

function drawGraph(w, x, y)
  love.graphics.setColor(255, 255, 255, 255)
  
  local px = 0
  local py = 0
  local value = 0
  
  for i = 1, #graph.data[w], 1 do
    local range = 5
    local yscale = graph.height / (range * 2)
  value = graph.data[w][i]
    px = x + (i - 1) / 100
    py = y - (value - range) * yscale
    love.graphics.point(px, py)
  end
  
  love.graphics.setColor(100, 100, 100, 255)
  
  love.graphics.line(
    x, y, 
    x + graph.width, y,
    x + graph.width, y + graph.height,
    x, y + graph.height,
    x, y)

    love.graphics.print(graph.title[w], x + graph.width / 2, y + 10)
    love.graphics.print("["..value.."]", px, py)
end

function drawInput()
  for _, v in pairs(input) do
    local x = v[1] * plot_size
    local y = plot_size - v[2] * plot_size
    local class = v[3]
  
    if class == 1 then
      love.graphics.setColor(0, 255, 0, 255)
    else
      love.graphics.setColor(255, 0, 0, 255)
    end
  
    love.graphics.circle("line", x, y, 5)
  end
end

function drawInfo()
  local s = "Weights:\n  w1 "..weights[1].."\n  w2 "..weights[2].."\n  w3 "..weights[3].."\n\n"
  s = s.."Error: "..average_error.." (thresold: "..error_thresold..")\n"
  s = s.."Learning rate: "..learning_rate.."\n"
  s = s.."Iterations: "..iteration_count
  love.graphics.print(s, 60, 50)
end

function drawPerceptron()
  local q = -weights[3] / weights[2] * plot_size
  local m = -weights[1] / weights[2]

  local x1 = -10
  local x2 = plot_size + 10
  
  local y1 = plot_size - (x1 * m + q)
  local y2 = plot_size - (x2 * m + q)

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.line(x1, y1, x2, y2);
end

function love.keypressed(key, unicode)
  if key == "escape" then
    love.event.push("quit")
  end
end

function string:split(pat)
  local st, g = 1, self:gmatch("()("..pat..")")
  local function getter(self, segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  local function splitter(self)
    if st then return getter(self, st, g()) end
  end
  return splitter, self
end