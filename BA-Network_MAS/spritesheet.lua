local lg = love.graphics

local Spritesheet = {}

local sprites_dir = "sprites/"

local sprites = {
  "assault.png", 
  "basic_minion_A.png", 
  "basic_minion_B.png", 
  "basic_minion_C.png", 
  "basic_minion_D.png", 
  "basic_minion_E.png", 
  "basic_minion_F.png",
  "director.png",
  "heavy.png",
  "super_minion_A.png",
  "super_minion_B.png",
  "super_minion_C.png",
  "support.png"
}

local function load(src)
  local tex = lg.newImage(sprites_dir..src)
  local ss = {
    src = src,
    tex = tex,
    quads = {},
    width = tex:getWidth(),
    height = tex:getHeight()}
  
  ss.frame_width = ss.width / 4
  ss.half_frame_width = ss.width / 8
  ss.frame_height = ss.height / 4
  ss.half_frame_height = ss.height / 8
  
  local x = 0
  local y = 0
  
  for _ = 1, 4, 1 do
    for _ = 1, 4, 1 do
      local quad = lg.newQuad(x, y, ss.frame_width, ss.frame_height, ss.width, ss.height)
      ss.quads[#ss.quads + 1] = quad
      x = x + ss.frame_width
    end
    y = y + ss.frame_height
    x = 0
  end
  
  return setmetatable(ss, Spritesheet)
end

Spritesheet.pool = {}

for _,v in pairs(sprites) do
  local ss = load(v)
  table.insert(Spritesheet.pool, ss)
end

function Spritesheet.get()
  return Spritesheet.pool[math.random(#Spritesheet.pool)]
end

return Spritesheet