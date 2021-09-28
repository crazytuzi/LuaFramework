local guoqingMgr = class("guoqingMgr")
function guoqingMgr:ctor()
  self.m_Status = 2
  self.m_XQSPStartTime = nil
  self.m_XQSPEndTime = nil
  self.m_XQSPCanGetState = nil
  self.m_XQSPData = nil
end
function guoqingMgr:setStatus(status)
  self.m_Status = status
  if g_MapMgr then
    local state = 0
    if self.m_Status == 1 then
      state = 1
    end
    g_MapMgr:updateDynamicActiveNpc({npcId = NPC_DuECanShi_ID, state = state})
  end
  SendMessage(MsgID_Activity_GuoQingStatus)
end
function guoqingMgr:SetGuoQingSuiPianData(data)
  self.m_XQSPStartTime = data.starttime or self.m_XQSPStartTime
  self.m_XQSPEndTime = data.endtime or self.m_XQSPEndTime
  self.m_XQSPCanGetState = data.baward or self.m_XQSPCanGetState
  if data.lst ~= nil then
    self.m_XQSPData = DeepCopyTable(data.lst)
  end
  SendMessage(MsgID_XianQiSuiPian_Update)
end
function guoqingMgr:getTimeData()
  return self.m_XQSPStartTime, self.m_XQSPEndTime
end
function guoqingMgr:getFinishData()
  return self.m_XQSPCanGetState, self.m_XQSPData
end
function guoqingMgr:getCanPlayerGetXQSP()
  if self.m_XQSPCanGetState == nil or self.m_XQSPData == nil then
    return false
  end
  for _, tData in pairs(self.m_XQSPData) do
    if tData.cnt < tData.limit then
      return false
    end
  end
  if self.m_XQSPCanGetState == 1 then
    return false
  end
  return true
end
function guoqingMgr:getPlayerGetXQSPText()
  local XQSPStr = ""
  if self.m_XQSPData == nil then
    return ""
  end
  local cntList = {}
  for tIndex, _ in pairs(data_GuoQinFinishCnt) do
    cntList[#cntList + 1] = tIndex
  end
  table.sort(cntList)
  for _, tIndex in ipairs(cntList) do
    for _, tData in ipairs(self.m_XQSPData) do
      if tData.id == tIndex then
        local dbData = data_GuoQinFinishCnt[tData.id]
        if dbData and dbData.Name then
          XQSPStr = string.format([[
%s
%s    %d/%d]], XQSPStr, dbData.Name, tData.cnt, tData.limit)
        end
      end
    end
  end
  return XQSPStr
end
function guoqingMgr:getStatus()
  return self.m_Status
end
return guoqingMgr
