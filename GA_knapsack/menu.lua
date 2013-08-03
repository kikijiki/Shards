local g = love.graphics

local M = {}
M.__index = M

function reserve(text, field, font, cell)
  local width = font:getWidth(text)
  local height = font:getHeight(text)

  cell[field] = math.max(cell[field], width)
  cell.height = math.max(cell.height, height)  
  
end

function M:new(items)
  local menu = {
    items = items,
    cell = {
      name = 0, cost = 0, time = 0, height = 0,
      padding = {x = 16, y = 4},
    },
    item_limit = 25,
    width = 0,
    font = g.newFont(12),
    border = 6,
    color = {
      background = {40, 40, 40},
      cell = {160, 160, 160},
      text = {220, 220, 220},
      border = {240, 240, 240},
    }
  }
  
  reserve("Name", "name", menu.font, menu.cell)
  reserve("Cost", "cost", menu.font, menu.cell)
  reserve("Time", "time", menu.font, menu.cell)

  for _,item in pairs(menu.items) do
    reserve(item.name, "name", menu.font, menu.cell)
    reserve(item.cost, "cost", menu.font, menu.cell)
    reserve(item.time, "time", menu.font, menu.cell)
  end
  
  return setmetatable(menu, self)
end

function M:draw(x, y)
  x, y = x + 1, y + 1
  local cell = self.cell
  local cname, ccost, ctime, cheight = cell.name, cell.cost, cell.time, cell.height
  local ccolor, tcolor = self.color.cell, self.color.text
  local px, py = cell.padding.x, cell.padding.y
  local bd = self.border
  local nitems = math.min(self.item_limit, #self.items)
  local height = (nitems + 1) * (cell.height + py) + bd * 2
  local width = cname + ccost + ctime + px * 2 + bd * 2
  
  if #self.items > self.item_limit then height = height + cheight end
  
  g.setColor(self.color.background)
  g.rectangle("fill", x, y, width, height)
  g.setColor(self.color.border)
  g.rectangle("line", x, y, width, height)
  
  local yy = y + bd
  local xx = x + bd
  local lx1, lx2 = x + bd, x + width - bd
  
  g.setColor(255, 100, 0)
  g.printf("Name", xx, yy, cname, "right")
  xx = xx + cname + px
  g.printf("Cost", xx, yy, ccost, "center")
  xx = xx + ccost + px
  g.printf("Time", xx, yy, ctime, "center")
  
  local count = 1
  yy = yy + py + cheight
  for _,item in pairs(self.items) do
    g.setColor(tcolor)
    xx = x + bd
    g.printf(item.name, xx, yy, cname, "right")
    xx = xx + cname + px
    g.printf(item.cost, xx, yy, ccost, "center")
    xx = xx + ccost + px
    g.printf(item.time, xx, yy, ctime, "center")
    yy = yy + cheight + py /2
    
    count = count + 1
    if count > self.item_limit then
      g.setColor(255, 0, 0)
      g.printf("and other "..(#self.items - self.item_limit).." items...", x + bd, yy, width - bd * 2, "center")
      break
    end
    
    g.setColor(ccolor)
    g.line(lx1, yy, lx2, yy)
    
    yy = yy + py / 2
  end
end

return M