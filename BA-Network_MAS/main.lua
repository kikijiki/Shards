local sim = require "simulation"
local lg = love.graphics

local screen = {
  width  = 1600,
  height = 1000,
  simulation = {width = 800, height = 1000, left =   0, right =  800, top = 0, bottom = 1000},
  graph      = {width = 800, height =  800, left = 800, right = 1600, top = 0, bottom =  800}
}

local buttons = {}

local t = 0
local revealed = false
local inc_step = 0.5
local inc_mod = 1.04
local limit = 300

function love.load(arg)
  sim.initialize(screen, false)
  for _ = 1, 1 do sim.addCharacter() end
  
  local font = lg.newFont("ipaexg.ttf", 16)
  lg.setFont(font)
  
  addButton(
    screen.graph.left + 70, 
    screen.graph.top + 70, 
    60,
    "秘密をばらす", 
    "ばらした！", 
    true,
    function()
      sim.revealSecret(active)
      revealed = true
    end)
    
  addButton(
    screen.graph.right - 70,
    screen.graph.bottom - 70, 
    60,
    "話題を\nくりまえす", 
    "話題を\n繰り返さない", 
    false,
    function(active)
      sim.norepeat = active
    end)    
    
  addButton(
    screen.graph.right - 70,
    screen.graph.top + 70, 
    60,
    "ソート無効", 
    "ソート有効", 
    false,
    function(active)
      sim.sortGraph = active
    end)      
end

function love.update(dt)
  t = t + dt

  while t > inc_step and #sim.characters < limit do
    t = t - inc_step
    sim.addCharacter()
  end
  
  --inc_step = inc_step * inc_mod
  
  if love.keyboard.isDown(" ") then sim.addCharacter() end
  
  sim.update(dt, screen.simulation.coord)
end

function love.mousepressed(x, y, btn)

  for _,b in pairs(buttons) do
    local sd = (x - b.x) * (x - b.x) + (y - b.y) * (y - b.y)
    if sd < b.r * b.r then
      if not b.pressed then
        b.callback(true)
        b.pressed = true
      else
        if not b.pressonce then
          b.pressed = false
          b.callback(false)
        end
      end
    end
  end
end

function love.draw()
  sim.draw()
  for _,b in pairs(buttons) do drawButton(b) end
end

function drawButton(b)
  if b.pressed then
    lg.setColor(b.color.active)
    lg.circle("fill", b.x, b.y, b.r, 40)
    lg.setColor(255, 255, 255, 255)
    lg.printf(b.text.active, b.x - b.r, b.y - 10, b.r * 2, "center")  
  else
    lg.setColor(b.color.inactive)
    lg.circle("fill", b.x, b.y, b.r, 40)
    lg.setColor(0, 0, 0, 255)
    lg.printf(b.text.inactive, b.x - b.r, b.y - 10, b.r * 2, "center")
  end
end

function addButton(x, y, r, textInactive, textActive,once, callback)
  local b = {
    x = x,
    y = y,
    r = r,
    sr = r * r,
    text = {active = textActive, inactive = textInactive},
    color = {active={255, 0, 0, 255}, inactive={139, 224, 27, 255}},
    pressed = false,
    pressonce = once,
    callback = callback
  }
  
  table.insert(buttons, b)
end

function shuffleArray(array)
  local arrayCount = #array
  for i = arrayCount, 2, -1 do
    local j = math.random(1, i)
    array[i], array[j] = array[j], array[i]
  end
  return array
end