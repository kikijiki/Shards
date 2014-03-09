local input = 10001
local primes = {[2] = true}
local i = 3
local count = 1

local function check(n)
  for v,_ in pairs(primes) do
    if n % v == 0 then return false end
  end
  return true
end

while count < input do
  if check(i) then
    primes[i] = true
    count = count + 1
  end
  i = i + 2
end

print(i - 2)