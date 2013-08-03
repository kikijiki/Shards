local M = {}
M.__index = M

local g = love.graphics

function M:new(width, height, max_cost, max_time)
  local graph = {
    width = width,
    height = height,
    data = {
      length = 0,
      generation = 0,
      best_cost = {},
      best_time = {},
      average_cost = {},
      average_time = {}},
    max_cost = max_cost,
    max_time = max_time,
    cost_scale = height / max_cost,
    time_scale = height / max_time,
    color = {
      axis = {255, 255, 255},
      best_cost = {255, 0, 0},
      best_time = {250, 200, 50},
      average_cost = {0, 255, 0},
      average_time = {60, 120, 255}}
  }
  return setmetatable(graph, self)
end

function M:append(best_cost, best_time, average_cost, average_time)
  local data = self.data
  data.length = data.length + 1
  table.insert(data.average_cost, math.floor(average_cost))
  table.insert(data.average_time, math.floor(-average_time))
  table.insert(data.best_cost, best_cost)
  table.insert(data.best_time, -best_time)
  
  if data.length > self.width then
    data.length = self.width
    table.remove(data.average_time, 1)
    table.remove(data.average_cost, 1)
    table.remove(data.best_cost, 1)
    table.remove(data.best_time, 1)
  end
  
  self.data.generation = self.data.generation + 1
end

function M:draw(x, y)
  local best_cost = self.data.best_cost
  local best_time = self.data.best_time
  local avg_cost = self.data.average_cost
  local avg_time = self.data.average_time
  
  g.setColor(0, 0, 0)
  g.rectangle("fill", x, y, self.width, self.height)
  
  g.setColor(self.color.axis)
  g.line(x, y, x, y + self.height)
  g.line(x, y + self.height, x + self.width, y + self.height)

  g.setColor(self.color.average_cost)
  self:plot(x, y, avg_cost, self.cost_scale, self.max_cost, false)
  g.printf("Average cost", x, y + self.height + 20, 150, "center")
  
  g.setColor(self.color.average_time)
  self:plot(x, y, avg_time, self.time_scale, self.max_time, false)
  g.printf("Average time", x + 150, y + self.height + 20, 150, "center")

  g.setColor(self.color.best_cost)
  self:plot(x, y, best_cost, self.cost_scale, self.max_cost, true)
  g.printf("Best individual (cost)", x + 300, y + self.height + 20, 150, "center")
  
  g.setColor(self.color.best_time)
  self:plot(x, y, best_time, self.time_scale, self.max_time, false)
  g.printf("Best individual (time)", x + 450, y + self.height + 20, 150, "center")
  
  g.setColor(255, 255, 255)
  g.print("Generation "..self.data.generation, x, y + self.height + 5)
end

function M:plot(x, y, points, scale, max, compare)
  if #points < 2 then return end
  local yy = math.max(math.min(max + 50, points[1]), -50) * scale
  local from = {x = x + 1, y = y + self.height - yy}
  local to = {x = 0, y = 0}
  local last
  
  for i = 2, #points do
    to.x = x + i
    yy = math.max(math.min(max + 50, points[i]), -50) * scale
    to.y = y + self.height - yy
    g.line(from.x, from.y, to.x, to.y)
    from.x = to.x
    from.y = to.y
    last = points[i]
  end

  if compare then
    if last == max then
      last = "optimum"
    else
      last = last.."/"..max
    end
  end
  
  g.print(last, to.x, to.y - 16)
end

return M