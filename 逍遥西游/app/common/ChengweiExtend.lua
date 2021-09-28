ChengweiExtend = {}
function ChengweiExtend.extend(object)
  function object:initChengwei()
    object.m_cw_CurId = 0
    object.m_cw_blName = nil
    object.m_cw_EndTime = nil
    object.m_cw_IsHide = 0
    object.m_cw_All = {}
    object.m_cw_Num = 0
    object:StartChengweiUpdateTimer()
  end
  function object:getAllChengwei()
    return object.m_cw_All, object.m_cw_Num
  end
  function object:getCurChengwei()
    if object.m_cw_EndTime ~= nil and g_DataMgr:getServerTime() > object.m_cw_EndTime then
      object.m_cw_CurId = 0
    end
    return object.m_cw_CurId, object.m_cw_EndTime, object.m_cw_IsHide
  end
  function object:getCurChengweiBanLvName()
    return object.m_cw_blName
  end
  function object:reciveCurChengwei(cwId, leftTime, hide)
    print("reciveCurChengwei:", cwId, leftTime, hide)
    if cwId == nil then
      object.m_cw_CurId = 0
    else
      object.m_cw_CurId = cwId
    end
    if leftTime ~= nil then
      object.m_cw_EndTime = g_DataMgr:getServerTime() + leftTime
    else
      object.m_cw_EndTime = nil
    end
    object.m_cw_IsHide = hide == 1
    SendMessage(MsgID_ChengWeiChanged, object.m_RoleId)
  end
  function object:syncChengweiInfo(wcId, blname)
    if object.m_cw_CurId ~= wcId then
      object.m_cw_CurId = wcId
      object.m_cw_EndTime = nil
      object.m_cw_IsHide = false
      object.m_cw_blName = blname
      SendMessage(MsgID_ChengWeiChanged, object.m_RoleId)
    end
  end
  function object:reciveAllChengwei(cwTalbe)
    object.m_cw_All = {}
    object.m_cw_Num = 0
    if cwTalbe then
      for i, v in ipairs(cwTalbe) do
        local cwId = v.id
        local leftTime = v.lefttime
        if cwId ~= nil then
          if leftTime ~= nil then
            leftTime = g_DataMgr:getServerTime() + leftTime
          end
          if object.m_cw_All[cwId] == nil then
            object.m_cw_Num = object.m_cw_Num + 1
          end
          object.m_cw_All[cwId] = {endTime = leftTime}
        end
      end
    end
    SendMessage(MsgID_ServerSendAllChengWei)
  end
  function object:updateChengweiTime(cwId, leftTime)
    if leftTime ~= nil then
      leftTime = g_DataMgr:getServerTime() + leftTime
    end
    if object.m_cw_All[cwId] then
      object.m_cw_All[cwId] = {endTime = leftTime}
      SendMessage(MsgID_ChengWeiTimeChanged, cwId)
    end
    if object.m_cw_CurId == cwId then
      object.m_cw_EndTime = leftTime
      SendMessage(MsgID_ChengWeiChanged, object.m_RoleId)
    end
  end
  function object:JudgeDelChengweiTime(cwId)
    local d = object.m_cw_All[cwId]
    local serverTime = g_DataMgr:getServerTime()
    if d and serverTime > 0 then
      local endTime = d.endTime
      if endTime and serverTime >= endTime then
        if data_Title[cwId] and data_Title[cwId].CostGold == 0 then
          object:delChengwei(cwId)
        elseif object.m_cw_CurId == cwId then
          object.m_cw_CurId = 0
          object.m_cw_EndTime = nil
          object.m_cw_IsHide = 0
          SendMessage(MsgID_ChengWeiChanged, object.m_RoleId)
        end
      end
    end
  end
  function object:delChengwei(cwId)
    print("\t delChengwei:", cwId)
    if object.m_cw_All[cwId] then
      object.m_cw_All[cwId] = nil
      object.m_cw_Num = object.m_cw_Num - 1
      if object.m_cw_Num < 0 then
        object.m_cw_Num = 0
      end
      SendMessage(MsgID_DeleteOneChengWei, cwId)
    end
    if object.m_cw_CurId == cwId then
      object.m_cw_CurId = 0
      object.m_cw_EndTime = nil
      object.m_cw_IsHide = 0
      SendMessage(MsgID_ChengWeiChanged, object.m_RoleId)
    end
  end
  function object:StartChengweiUpdateTimer()
    if object.m_ChengweiUpdateTimer then
      scheduler.unscheduleGlobal(object.m_ChengweiUpdateTimer)
    end
    object.m_ChengweiUpdateTimer = scheduler.scheduleGlobal(function()
      if object.CheckChengweiUpdate then
        object:CheckChengweiUpdate()
      end
    end, 1)
  end
  function object:DelChengweiUpdateTimer()
    if object.m_ChengweiUpdateTimer then
      scheduler.unscheduleGlobal(object.m_ChengweiUpdateTimer)
      object.m_ChengweiUpdateTimer = nil
    end
  end
  function object:CheckChengweiUpdate()
    for cwId, _ in pairs(object.m_cw_All) do
      object:JudgeDelChengweiTime(cwId)
    end
  end
  object:initChengwei()
end
