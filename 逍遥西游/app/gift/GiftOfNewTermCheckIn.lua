local GiftOfNewTermCheckIn = class("GiftOfNewTermCheckIn")
function GiftOfNewTermCheckIn:ctor()
  self.m_StartTime = nil
  self.m_EndTime = nil
  self.m_State = nil
  self.m_DayNum = nil
end
function GiftOfNewTermCheckIn:setNewTermCheckInData(data)
  self.m_StartTime = data.i_start or self.m_StartTime
  self.m_EndTime = data.i_end or self.m_EndTime
  self.m_State = data.i_s or self.m_State
  self.m_DayNum = data.i_n or self.m_DayNum
  SendMessage(MsgID_Gift_NewTermCheckInUpdate)
end
function GiftOfNewTermCheckIn:IsInNewTermTime()
  local curTime = g_DataMgr:getServerTime()
  if self.m_StartTime == nil or self.m_EndTime == nil then
    return false
  end
  if curTime <= self.m_StartTime or curTime >= self.m_EndTime then
    return false
  end
  return true
end
function GiftOfNewTermCheckIn:getNewTermCheckInTimeData()
  return self.m_StartTime, self.m_EndTime
end
function GiftOfNewTermCheckIn:GetNewTermCheckInDay()
  return self.m_DayNum
end
function GiftOfNewTermCheckIn:IsCanNewTermCheckInToday()
  if self:IsInNewTermTime() == false then
    return false
  end
  return self.m_State == 0
end
function GiftOfNewTermCheckIn:getIsCanAccept(day)
  if self:IsCanNewTermCheckInToday() == false then
    return false
  end
  if self.m_DayNum == nil then
    return false
  end
  if self.m_DayNum + 1 == day then
    return true
  end
  return false
end
function GiftOfNewTermCheckIn:getIsHasAccept(day)
  if self.m_DayNum == nil then
    return false
  end
  if day < self.m_DayNum + 1 then
    return true
  end
  return false
end
function GiftOfNewTermCheckIn:GetNewTermCheckInDayNum()
  return self.m_DayNum
end
return GiftOfNewTermCheckIn
