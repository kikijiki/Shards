local lg = love.graphics

local Animation = {}
Animation.__index = Animation

function Animation.new(ss)
  local a = {
    ss = ss,
    frames = {
      up = {ss.quads[13], ss.quads[14], ss.quads[15], ss.quads[16]},
      down = {ss.quads[1], ss.quads[2], ss.quads[3], ss.quads[4]},
      left = {ss.quads[5], ss.quads[6], ss.quads[7], ss.quads[8]},
      right = {ss.quads[9], ss.quads[10], ss.quads[11], ss.quads[12]},
    },
    frame_length = 0.1, --S
    elapsed = 0,
    current_frame = 1,
    active = true
  }

  return setmetatable(a, Animation)
end

function Animation:update(dt)
  if not self.active then return end
  self.elapsed = self.elapsed + dt
  
  if self.elapsed >= self.frame_length then
    self.elapsed = self.elapsed - self.frame_length
    self.current_frame = self.current_frame + 1
    if self.current_frame > 4 then
      self.current_frame = 1
    end
  end
end

function Animation:draw(position, direction)
  local quad = self.frames[direction][self.current_frame]
  lg.drawq(self.ss.tex, quad, position.x - self.ss.frame_width / 2, position.y - self.ss.frame_height)
end

return Animation