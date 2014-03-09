local input = 20
local factors = {}
local buffer = {}
local factor = 2

for i=1, input do buffer[i] = i end

function finished()
  for _,v in pairs(buffer) do
    if v ~= 1 then return false end
  end
  return true
end

function update()
  local tmp = {}
  local updated = false
  for k,v in pairs(buffer) do
    if buffer[k] % factor == 0 then
      tmp[k] = buffer[k] / factor
      updated = true
    else
      tmp[k] = buffer[k]
    end
  end
  if updated then
    table.insert(factors, factor)
  else
    factor = factor + 1
  end
  buffer = tmp
end

while not finished() and factor <= input do
  update()
end

local ret = 1
for _,v in pairs(factors) do
  print(v)
  ret = ret * v
end

print(ret)