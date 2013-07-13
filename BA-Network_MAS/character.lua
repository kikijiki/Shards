local Spritesheet = require "spritesheet"
local Animation = require "animation"
local Names = require "names"
local lg = love.graphics

local Character = {}
Character.__index = Character;

local Rumors = {
  "研究室のエアコン故障している",
  "中間発表のあと飲み会やる",
  "奨学金あした締め切りだ",
  "今週は映画館で学割５０％だよ",
  "ヌテッラ美味しいけどむっちゃ高い",
  "今日の粉クリのチーズタルトやや大きい",
  "明後日は全学停電になってる",
  "今日は３５度だぞ！"
}

local directions = {"up", "down", "left", "right"}

local function addRandomRumor(c)
  local check = true
  local r = nil
  
  while check do
    r = Rumors[math.random(#Rumors)]
    for _,v in pairs(c.rumors) do
      if v == r then check = true end
    end
    check = false
  end  
  
  table.insert(c.rumors, r)
end

function Character.new()
  local spritesheet = Spritesheet.get()
  local c = {
    name = Names.next(),
    
    ss = spritesheet,
    anim = Animation.new(spritesheet),
    pos = {x = 0, y = 0},
    direction = "up",
    speed = math.random(40, 100),
    turn = {wait = math.random() * 10, prob = 50, ela = 0},
    
    rumors = {},
    friends = {count = 0},
    recent = {}
  }
  
  addRandomRumor(c)
  addRandomRumor(c)
  addRandomRumor(c)
  
  return setmetatable(c, Character)
end

function Character:update(dt, viewport)
  if self.talking then return end
  
  for i,v in pairs(self.recent) do
    self.recent[i] = v - dt
    if self.recent[i] < 0 then self.recent[i] = nil end
  end
  
  self:move(dt, viewport)
  self.anim:update(dt)
end

function Character:know(rumor)
  for _,v in pairs(self.rumors) do
    if v == rumor then return true end
  end
  return false
end

function Character:draw()
  lg.setColor(255, 255, 255, 255)
  self.anim:draw(self.pos, self.direction)
  if self.knows then lg.setColor(255, 0, 0, 255)
  else lg.setColor(255, 255, 255, 255) end
  lg.printf(
    self.name, 
    self.pos.x - self.ss.half_frame_width, 
    self.pos.y - 10 - self.ss.frame_height, 
    self.ss.frame_width, 
    "center" )
  
  --bounding box
  --lg.rectangle("line", self.pos.x - self.ss.half_frame_width, self.pos.y - self.ss.frame_height, self.ss.frame_width, self.ss.frame_height)
  
  if self.talking and self.current_rumor then
    local f = lg.getFont()
    local w = f:getWidth(self.current_rumor)
  
    if self.secret and self.current_rumor == self.secret then lg.setColor(255, 0, 0, 255)
    else lg.setColor(255, 255, 255, 255) end
    lg.rectangle("fill", self.pos.x + 40, self.pos.y - self.ss.frame_height - 20, w + 20, 30)
    
    lg.setColor(0, 0, 0, 255)
    lg.printf(self.current_rumor, self.pos.x + 50, self.pos.y - self.ss.frame_height - 10,100, "left")
  end
end

function Character:move(dt, viewport)
  self.turn.ela = self.turn.ela + dt
  if self.turn.ela > self.turn.wait then
    self.turn.wait = math.random() * 10
    self.turn.ela = self.turn.ela - self.turn.wait
    if math.random(100) < self.turn.prob then self.direction = directions[math.random(#directions)] end
  end
  
  if self.direction ==    "up" then self.pos.y = self.pos.y - self.speed * dt end
  if self.direction ==  "down" then self.pos.y = self.pos.y + self.speed * dt end
  if self.direction ==  "left" then self.pos.x = self.pos.x - self.speed * dt end
  if self.direction == "right" then self.pos.x = self.pos.x + self.speed * dt end
  
  if self.pos.x < viewport.left  + self.ss.half_frame_width then self.pos.x = viewport.left  + self.ss.half_frame_width; self.direction = "right" end
  if self.pos.x > viewport.right - self.ss.half_frame_width then self.pos.x = viewport.right - self.ss.half_frame_width; self.direction =  "left" end
  if self.pos.y < viewport.top   + self.ss.frame_height     then self.pos.y = viewport.top   + self.ss.frame_height    ; self.direction =  "down" end
  if self.pos.y > viewport.bottom                           then self.pos.y = viewport.bottom                          ; self.direction =    "up" end
end

function Character:look(dir)
  self.direction = dir
end

function Character:addRumor(rumor)
  for _,v in pairs(self.rumors) do
    if v == rumor then return end
  end
  table.insert(self.rumors, rumor)
end

function Character:getRumor(other, norepeat)
  if self.secret and not other.secret then 
    if math.random(100) < 75 then return self.secret end
  end
  
  if norepeat then
    local possible_rumors = {}
    for i,v in pairs(self.rumors) do
      if not other:know(v) then table.insert(possible_rumors, v) end
    end
  
    if #possible_rumors > 0 then return possible_rumors[math.random(#possible_rumors)]
    else return nil end
  else
    return self.rumors[math.random(#self.rumors)]
  end
end

return Character