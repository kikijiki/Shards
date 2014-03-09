local primes = {}
local input = 600851475143
local i = 3

local function check(n)
  for v,_ in pairs(primes) do
    if n % v == 0 then return false end
  end
  return true
end

while (i * i) < input do
  if input % i == 0 and check(i) then
    primes[i] = true
    print(i)
  end
  i = i + 2
end