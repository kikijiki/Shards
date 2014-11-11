local n = {}
local size = 2000000

for i = 2, size do n[i] = true end
for i = 2, math.floor(math.sqrt(size)) do
  if n[i] then
    for j = i * i, size, i do
      n[j] = nil
    end
  end
end

local sum = 0

for i,_ in pairs(n) do sum = sum + i end

print("The sum is "..sum)