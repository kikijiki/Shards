local function fib(x)
  if x == 0 then return 0 end
  
  local a = 0
  local b = 1
  local c = 2
  local d
 
  while c < x do
    d = b
    b = a + b
    a = d
    c = c + 1
  end
  
  return a + b
end

local x = 1
local y = 1
local sum = 0

while y <= 4000000 do
  if y % 2 == 0 then sum = sum + y end
  x = x + 1
  y = fib(x)
end

print(sum)