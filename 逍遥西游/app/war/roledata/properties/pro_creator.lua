if not Properties then
  Properties = {}
end
function Properties.extend(object)
  object.PropertyValueDict = {}
  function object:getProperty(proType)
    local pro = object.PropertyValueDict[proType]
    if pro then
      return pro[1] or 0
    end
    return 0
  end
  function object:setProperty(proType, value)
    if value then
      local oldValue = object:getProperty(proType)
      if object.PropertyValueDict[proType] == nil then
        object.PropertyValueDict[proType] = {}
      end
      if value == 0 then
        object.PropertyValueDict[proType][1] = nil
      else
        object.PropertyValueDict[proType][1] = value
      end
      if object.PropertyValueDict[proType][1] == nil and object.PropertyValueDict[proType][2] == nil and object.PropertyValueDict[proType][3] == nil then
        object.PropertyValueDict[proType] = nil
      end
      object:PropertyChanged(proType, PROPERTY_CHANGED_NORMAL, value, oldValue)
    else
      printLogDebug("Properties", "[ERROR]设置属性值(%s)为nil1", proType)
    end
  end
  function object:getMaxProperty(proType)
    local pro = object.PropertyValueDict[proType]
    if pro then
      return pro[2] or 0
    end
    return 0
  end
  function object:setMaxProperty(proType, value)
    if value then
      local oldValue = object:getProperty(proType)
      if object.PropertyValueDict[proType] == nil then
        object.PropertyValueDict[proType] = {}
      end
      if value == 0 then
        object.PropertyValueDict[proType][2] = nil
      else
        object.PropertyValueDict[proType][2] = value
      end
      if object.PropertyValueDict[proType][1] == nil and object.PropertyValueDict[proType][2] == nil and object.PropertyValueDict[proType][3] == nil then
        object.PropertyValueDict[proType] = nil
      end
      object:PropertyChanged(proType, PROPERTY_CHANGED_MAX, value, oldValue)
    else
      printLogDebug("Properties", "[ERROR]设置属性值(%s)为nil4", proType)
    end
  end
  function object:getTempProperty(proType)
    local pro = object.PropertyValueDict[proType]
    if pro then
      return pro[3] or 0
    end
    return 0
  end
  function object:setTempProperty(proType, value)
    if value then
      local oldValue = object:getProperty(proType)
      if object.PropertyValueDict[proType] == nil then
        object.PropertyValueDict[proType] = {}
      end
      if value == 0 then
        object.PropertyValueDict[proType][3] = nil
      else
        object.PropertyValueDict[proType][3] = value
      end
      if object.PropertyValueDict[proType][1] == nil and object.PropertyValueDict[proType][2] == nil and object.PropertyValueDict[proType][3] == nil then
        object.PropertyValueDict[proType] = nil
      end
      object:PropertyChanged(proType, PROPERTY_CHANGED_TEMP, value, oldValue)
    else
      printLogDebug("Properties", "[ERROR]设置属性值(%s)为nil2", proType)
    end
  end
  function object:getOwnPropertyValueDict()
    return object.PropertyValueDict
  end
  function object:setPropertyChanagedListener(listener)
    object.m_PropertyChangedListener = listener
  end
  function object:PropertyChanged(propertyType, changedType, value_new, value_old)
    if object.m_PropertyChangedListener then
      object.m_PropertyChangedListener(object, propertyType, changedType, value_new, value_old)
    end
  end
end
