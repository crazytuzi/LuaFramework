DoubleExpExtend = {}
function DoubleExpExtend.extend(object)
  object.m_DoubleExpData = {}
  function object:setDoubleExpData(deP, deRestP, useSBDTimes)
    if deP ~= nil then
      local oldDep = object.m_DoubleExpData.deP or 0
      object.m_DoubleExpData.deP = deP
      if deP > oldDep and g_MissionMgr then
        g_MissionMgr:SetMissionHasAddDoubleExpFlag(true)
      end
    end
    if deRestP ~= nil then
      object.m_DoubleExpData.deRestP = deRestP
    end
    if useSBDTimes ~= nil then
      object.m_DoubleExpData.useSBDTimes = useSBDTimes
    end
    SendMessage(MsgID_DoubleExpUpdate, {
      pid = object.m_RoleId,
      deP = deP,
      deRestP = deRestP,
      useSBDTimes = useSBDTimes
    })
  end
  function object:getDoubleExpData()
    return DeepCopyTable(object.m_DoubleExpData)
  end
  function object:getDoubleExpPoint()
    local dp = object.m_DoubleExpData.deP or 0
    return dp
  end
end
return DoubleExpExtend
