if not RandomKangData then
  RandomKangData = {}
end
function RandomKangData.extend(object)
  object.randomKang = {
    {},
    {}
  }
  function object:setRandomKang(proName, value, num, calculateFlag)
    if calculateFlag == nil then
      calculateFlag = true
    end
    local t = {}
    t[proName] = value
    object.randomKang[num] = t
    if calculateFlag then
      object:CalculateProperty()
    end
  end
  function object:getRandomKang()
    local t = {}
    local pairs = pairs
    for _, data in ipairs(object.randomKang) do
      for pro, value in pairs(data) do
        t[pro] = value
      end
    end
    return t
  end
  function object:GetRandomKangByName(proName)
    local t = {}
    local pairs = pairs
    for _, data in ipairs(object.randomKang) do
      for pro, value in pairs(data) do
        t[pro] = value
      end
    end
    return t[proName] or 0
  end
  function object:getRandomKangSerialization()
    local cloneRandomKang = {}
    local pairs = pairs
    for k, v in pairs(object.randomKang) do
      local tempData = {}
      for tk, tv in pairs(v) do
        tempData[tk] = tv
      end
      cloneRandomKang[k] = tempData
    end
    return cloneRandomKang
  end
  function object:setRandomKangSerialization(proSerialization, calculateFlag)
    if calculateFlag == nil then
      calculateFlag = true
    end
    object.randomKang = {}
    if proSerialization then
      local pairs = pairs
      for index, data in pairs(proSerialization) do
        local newData = {}
        for proName, num in pairs(data) do
          newData[proName] = num
        end
        object.randomKang[index] = newData
      end
      if calculateFlag then
        object:CalculateProperty()
      end
    end
  end
end
