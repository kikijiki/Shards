local Character = require "character"

local lg = love.graphics

local sim = {
  connectionsCount = 0,
  singleMaxConnectionsCount = 0,
  characters = {},
  discussions = {},
  secret = "先生が屁を放いた！！",
  sortGraph = false,
  norepeat = false,
}

local renderlist = {}

function sim.talk(a, b)
  local r1 = a:getRumor(b, sim.norepeat)
  local r2 = b:getRumor(a, sim.norepeat)
  
  if not r1 and not r2 then return end
  
  a.recent[b] = math.random() * 2;
  b.recent[a] = math.random() * 2;
  
  local d = {
    partecipants = {a, b},
    duration = math.random(1, 4), 
    content = {}
  }
  
  if r1 then table.insert(d.content, r1) end
  if r2 then table.insert(d.content, r2) end

  sim.discussions[d] = d
  
  a.talking = true; a.current_rumor = r1
  b.talking = true; b.current_rumor = r2
  
  if a.pos.x < b.pos.x then
    a:look("right")
    b:look("left")
  else
    a:look("left")
    b:look("right")
  end

  sim.link(a, b)
end

function sim.link(a, b)
  sim.addFriend(a, b)
  sim.addFriend(b, a)
end

function sim.addFriend(character, newFriend)
  if not character.friends[newFriend] then
    character.friends[newFriend] = newFriend
    character.friends.count = character.friends.count + 1
    sim.connectionsCount = sim.connectionsCount + 1
  end
  
  if character.friends.count > sim.singleMaxConnectionsCount then
    sim.singleMaxConnectionsCount = character.friends.count
  end
end

local function intersect(a, b)
  local ax1 = a.pos.x - a.ss.half_frame_width
  local ax2 = a.pos.x + a.ss.half_frame_width
  local ay1 = a.pos.y - a.ss.frame_height
  local ay2 = a.pos.y
  local bx1 = b.pos.x - b.ss.half_frame_width
  local bx2 = b.pos.x + b.ss.half_frame_width
  local by1 = b.pos.y - b.ss.frame_height
  local by2 = b.pos.y  
  
  return not (ax1 < bx2 and ax2 > bx1 and ay1 < by2 and ay2 > by1)
end

local function collisionDetection(a, b)
  if intersect(a, b) then return end            -- are they close?
  if a.talking or b.talking then return end     -- are they already talking?
  if a.recent[b] or b.recent[a] then return end -- did they recently speak?

  local p = 0
  if sim.connectionsCount then p = 0.1
  else p = b.friends.count / sim.connectionsCount * 100 end
  
  if a.secret or b.secret and not (a.secret and b.secret) then p = p * 2 end
  
  if (math.random() * 100) < p then
    sim.talk(a, b)
  end
end

function sim.initialize(screen, norepeat)
  sim.screen = screen
  sim.norepeat = norepeat
end

function sim.addCharacter()
  local c = Character.new()
  c.pos.x = math.random(sim.screen.simulation.width)
  c.pos.y = math.random(sim.screen.simulation.height)
  
  table.insert(sim.characters, c)
  table.insert(renderlist, c)
end

function sim.updateDiscussion(dt, d)
  d.duration = d.duration - dt
  if d.duration < 0 then
    local c1 = d.partecipants[1]
    local c2 = d.partecipants[2]
  
    c1.talking = false
    c2.talking = false
    
    for _,v in pairs(d.content) do
      c1:addRumor(v)
      c2:addRumor(v)
      if v == sim.secret then
        c1.secret = sim.secret
        c2.secret = sim.secret
      end
    end
    
    sim.discussions[d] = nil
    
    if c1.direction == "left" then c1.direction = "right" else c1.direction = "left" end
    if c2.direction == "left" then c2.direction = "right" else c2.direction = "left" end
  end
end

function sim.revealSecret()
  local c = sim.characters[next(sim.characters)]
  for _,v in pairs(sim.characters) do
    if v.friends.count > c.friends.count then c = v end
  end
  c:addRumor(sim.secret)
  c.secret = sim.secret
end

function sim.drawGraph()
  local vp = sim.screen.graph
  if sim.sortGraph then
    table.sort(sim.characters, function(a, b) return a.friends.count < b.friends.count end)
  end
  
  lg.setColor(0, 0, 0, 255)
  lg.rectangle("fill", vp.left, vp.top, vp.right, sim.screen.height)
  
  local da = 2 * math.pi / #sim.characters
  local a = 0
  local cntx = vp.left + vp.width / 2
  local cnty = vp.top + vp.height / 2
  local r = math.min(vp.width / 2, vp.height / 2) * 0.6
  local r2 = r + 80
  
  local loc = {}
  
  for _,c in pairs(sim.characters) do
    local x = cntx + r * math.cos(a); local xt = cntx + r2 * math.cos(a)
    local y = cnty + r * math.sin(a); local yt = cnty + r2 * math.sin(a)
    local w = lg.getFont():getWidth(c.name)

    lg.push()
      lg.translate(xt, yt)
      
      if a > math.pi/2 and a < math.pi * 3/2 then lg.rotate(a + math.pi)
      else lg.rotate(a) end
    
      lg.translate(-w/2, -8)
      
      if c.secret then lg.setColor(255, 0, 0, 255)
      else lg.setColor(255, 255, 255, 255) end
    
      lg.print(c.name, 0, 0)
    lg.pop()
    
    lg.setColor(255, 255, 255, 255)
    lg.circle("fill", x, y, 12, 10)
    
    loc[c] = {x, y}
    
    a = a + da
  end
 
  lg.setColor(255, 255, 255, 255)
  for _,c in pairs(sim.characters) do
    for _,v in pairs(c.friends) do
      if type(v) == "table" then
        lg.line(loc[c][1], loc[c][2], loc[v][1], loc[v][2])
      end
    end
  end
  
  lg.setColor(0, 0, 0, 255)
  for _,c in pairs(sim.characters) do
    lg.print(c.friends.count, loc[c][1] - 6, loc[c][2] - 6)
  end
  
  lg.setColor(255, 255, 255, 255)
  local left = vp.left
  local bottom = sim.screen.height - 50
  local width = 780
  local height = 80
  lg.line(left, bottom, left, bottom - height)
  lg.line(left, bottom, left + width, bottom)
  
  local bar = 30
  
  for i = 0, 20 do
    local count = 0
    for _,v in pairs(sim.characters) do
      if v.friends.count == i then count = count + 1 end
    end
    
    if count > 0 then
      local height = count
      local x = left + i * bar
      lg.line(x, bottom, x, bottom - height, x + bar, bottom - height, x + bar, bottom)
      lg.printf(i, x, bottom + 10, bar, "center")
      lg.printf(count, x, bottom - height - 15, bar, "center")
    end
  end
end

function sim.update(dt)
  for _,c in pairs(sim.characters) do 
    c:update(dt, sim.screen.simulation)
  end
  
  for _,d in pairs(sim.discussions) do
    sim.updateDiscussion(dt, d)
  end
  
  for i = 1, #sim.characters - 1 do
    for j = i + 1, #sim.characters do
      collisionDetection(sim.characters[i], sim.characters[j])
    end
  end
end

function sim.draw()
  table.sort(renderlist, function(a,b) return a.pos.y < b.pos.y end)
  for _,c in pairs(renderlist) do c:draw() end
  
  sim.drawGraph()
end

return sim