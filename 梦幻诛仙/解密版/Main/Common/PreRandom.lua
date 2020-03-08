local PreRandom = {}
local preRandomQueue = {}
function PreRandom.PreRandom(...)
  local result = math.random(...)
  table.insert(preRandomQueue, result)
  return result
end
function PreRandom.Random(...)
  local result
  local top = preRandomQueue[1]
  if top then
    table.remove(preRandomQueue, 1)
    result = top
  else
    result = math.random(...)
  end
  return result
end
return PreRandom
