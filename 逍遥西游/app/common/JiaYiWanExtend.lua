JiaYiWanExtend = {}
function JiaYiWanExtend.extend(object)
  object.m_JiaYiWanPetId = nil
  object.m_JiaYiWanUpdateTimer = nil
  object.m_JiaYiWanEndPoint = nil
  function object:SetJiaYiWanData(petId, endTimePoint)
    object.m_JiaYiWanPetId = petId
    object.m_JiaYiWanEndPoint = endTimePoint
    if object.m_JiaYiWanUpdateTimer then
      scheduler.unscheduleGlobal(object.m_JiaYiWanUpdateTimer)
    end
    object.m_JiaYiWanUpdateTimer = scheduler.scheduleGlobal(function()
      if object.CheckJiaYiWanData then
        object:CheckJiaYiWanData()
      end
    end, 1)
    SendMessage(MsgID_ItemInfo_JiaYiWanDataUpdate)
  end
  function object:GetJiaYiWanPetId()
    return object.m_JiaYiWanPetId
  end
  function object:GetJiaYiWanRestTime()
    if object.m_JiaYiWanEndPoint == nil or object.m_JiaYiWanPetId == nil then
      return 0
    end
    local curTime = g_DataMgr:getServerTime()
    local restTime = object.m_JiaYiWanEndPoint - curTime
    if restTime < 0 then
      return 0
    else
      return restTime
    end
  end
  function object:CheckJiaYiWanData()
    local curTime = g_DataMgr:getServerTime()
    local oldPetId = object.m_JiaYiWanPetId
    if object.m_JiaYiWanEndPoint == nil then
      object.m_JiaYiWanPetId = nil
    elseif curTime >= object.m_JiaYiWanEndPoint then
      object.m_JiaYiWanPetId = nil
    end
    if oldPetId ~= object.m_JiaYiWanPetId then
      SendMessage(MsgID_ItemInfo_JiaYiWanDataUpdate)
    end
  end
  function object:DelJiaYiWanUpdateTimer()
    if object.m_JiaYiWanUpdateTimer then
      scheduler.unscheduleGlobal(object.m_JiaYiWanUpdateTimer)
      object.m_JiaYiWanUpdateTimer = nil
    end
  end
end
return JiaYiWanExtend
