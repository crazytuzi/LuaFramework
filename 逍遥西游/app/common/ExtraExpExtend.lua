ExtraExpExtend = {}
function ExtraExpExtend.extend(object)
  object.m_ExtraExpFlag = 0
  object.m_ExtraExpItemList = {}
  object.m_ExtraExpUpdateTimer = nil
  function object:IsHasExtraExp()
    if object:GetExtraExpFlag() == 1 then
      return true
    end
    local extraItemFlag = false
    local curTime = g_DataMgr:getServerTime()
    for itemId, endTime in pairs(object.m_ExtraExpItemList) do
      if endTime > curTime then
        extraItemFlag = true
      end
    end
    if extraItemFlag then
      return true
    end
    return false
  end
  function object:SetExtraExpFlag(flag)
    object.m_ExtraExpFlag = flag
    SendMessage(MsgID_ExtraExpFlag, flag)
  end
  function object:GetExtraExpFlag()
    return object.m_ExtraExpFlag
  end
  function object:SetExtraExpItemList(list)
    local newList = {}
    for _, tData in pairs(list) do
      local itemId = tData.id
      local endTimePoint = tData.tp
      if itemId then
        newList[itemId] = endTimePoint
      end
    end
    object.m_ExtraExpItemList = newList
    if object.m_ExtraExpUpdateTimer then
      scheduler.unscheduleGlobal(object.m_ExtraExpUpdateTimer)
    end
    object.m_ExtraExpUpdateTimer = scheduler.scheduleGlobal(function()
      if object.CheckExtraExpItemList then
        object:CheckExtraExpItemList()
      end
    end, 1)
    SendMessage(MsgID_ExtraExpItemChange)
  end
  function object:GetExtraExpItemList()
    return object.m_ExtraExpItemList
  end
  function object:CheckExtraExpItemList()
    local delList = {}
    local curTime = g_DataMgr:getServerTime()
    for itemId, endTime in pairs(object.m_ExtraExpItemList) do
      if endTime < curTime then
        delList[#delList + 1] = itemId
      end
    end
    local changeFlag = false
    for _, itemId in pairs(delList) do
      changeFlag = true
      object.m_ExtraExpItemList[itemId] = nil
    end
    if changeFlag then
      SendMessage(MsgID_ExtraExpItemChange)
    end
  end
  function object:DelExtraExpUpdateTimer()
    if object.m_ExtraExpUpdateTimer then
      scheduler.unscheduleGlobal(object.m_ExtraExpUpdateTimer)
      object.m_ExtraExpUpdateTimer = nil
    end
  end
end
return ExtraExpExtend
