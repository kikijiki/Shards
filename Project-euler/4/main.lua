local maxv = 0
local maxs
for i = 1, 999 do
  for j = 1, 999 do
    local v = i * j
    local s = tostring(v)
    if s == string.reverse(s) and v > maxv then
      maxs = s
      maxv = v
    end
  end
end

print(maxs)