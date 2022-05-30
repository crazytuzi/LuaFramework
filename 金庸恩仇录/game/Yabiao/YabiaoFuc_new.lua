local data_config_yabiao_config_yabiao = require("data.data_config_yabiao_config_yabiao")
local timeGourp = {}
function randomPosX(time, id)
  local timeTotal = data_config_yabiao_config_yabiao[16].value
  local timeSpan = data_config_yabiao_config_yabiao[20].value
  for i = 0, timeTotal - 1, timeSpan do
    if time >= i * 60 and time < (i + timeSpan) * 60 then
      for k, v in pairs(timeGourp) do
        for k1, v1 in pairs(v) do
          if v1.id == id then
            table.insert(timeGourp[i + 1], v1)
            table.remove(v, k1)
            return v1.seed
          end
        end
      end
      do
        local index = 0
        local getRandom
        function getRandom()
          local seed = math.random(1, 4)
          index = index + 1
          if index > 5 then
            return seed
          end
          local isDouble = false
          for key1, v1 in pairs(timeGourp[i + 1]) do
            if v1.id == id then
              isDouble = true
              return v1.seed
            elseif v1.seed == seed then
              isDouble = true
              break
            end
          end
          if #timeGourp[i + 1] == 4 then
            return math.random(1, 4)
          end
          if not isDouble then
            local role = {}
            role.seed = seed
            role.id = id
            table.insert(timeGourp[i + 1], role)
            return seed
          end
          return getRandom()
        end
        return getRandom()
      end
    end
  end
end
function clearCache(id)
  for k, v in pairs(timeGourp) do
    for k1, v1 in pairs(v) do
      if v1.id == id then
        table.remove(v, k1)
        dump(timeGourp)
        break
      end
    end
  end
end
function initTimeGroup()
  local timeTotal = data_config_yabiao_config_yabiao[16].value
  local timeSpan = data_config_yabiao_config_yabiao[20].value
  for i = 0, timeTotal, timeSpan do
    timeGourp[i + 1] = {}
  end
end
initTimeGroup()
