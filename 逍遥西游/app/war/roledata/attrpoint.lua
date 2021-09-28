if not AttrPoint then
  AttrPoint = {}
end
function AttrPoint.extend(object)
  object.attrPoint = {}
  function object:addAttrPoint(proName, calculateFlag)
    if calculateFlag == nil then
      calculateFlag = true
    end
    if object.attrPoint[proName] ~= nil then
      object.attrPoint[proName] = object.attrPoint[proName] + 1
    else
      object.attrPoint[proName] = 1
    end
    if calculateFlag then
      object:CalculateProperty()
    end
  end
  function object:delAttrPoint(proName, calculateFlag)
    if calculateFlag == nil then
      calculateFlag = true
    end
    if object.attrPoint[proName] ~= nil then
      object.attrPoint[proName] = object.attrPoint[proName] - 1
    else
      printLogDebug("attrpoint", "没有属性点:%s，还要减少", proName)
      object.attrPoint[proName] = 0
    end
    if calculateFlag then
      object:CalculateProperty()
    end
  end
  function object:getAttrPoint()
    return object.attrPoint
  end
  function object:GetAttrPointNum(proName)
    local num = object.attrPoint[proName] or 0
    return num
  end
  function object:getAttrPointSerialization()
    local cloneAttrPoint = {}
    for k, v in pairs(object.attrPoint) do
      cloneAttrPoint[k] = v
    end
    return cloneAttrPoint
  end
  function object:setAttrPointSerialization(proSerialization, calculateFlag)
    if calculateFlag == nil then
      calculateFlag = true
    end
    object.AttrPoint = {}
    if proSerialization then
      for proName, num in pairs(proSerialization) do
        object.attrPoint[proName] = num
      end
      if calculateFlag then
        object:CalculateProperty()
      end
    end
  end
end
