local online = class("CGiftOfOnline")
function online:ctor()
  self.m_CurDoId = -1
  self.m_NextCmpTime = 0
  MessageEventExtend.extend(self)
end
function online:dataUpdate(id, lefttime)
  if id ~= nil then
    self.m_CurDoId = id
  end
  if lefttime ~= nil then
    self.m_NextCmpTime = g_DataMgr:getServerTime() + lefttime
  end
  SendMessage(MsgID_Gift_OnlineRewardUpdate)
end
function online:getRewardId()
  return self.m_CurDoId
end
function online:getNextCmpTime(...)
  return self.m_NextCmpTime
end
function online:getReward(id)
  local d = data_GiftOfOnline[id or self.m_CurDoId]
  if d then
    return d.reward
  end
  return {}
end
function online:OnMessage(msgSID, ...)
end
return online
