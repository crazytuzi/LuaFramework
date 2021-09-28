local checkin = class("CGiftOfCheckin")
function checkin:ctor()
  self.m_CheckinCount = 0
  self.m_ReCheckinCount = 0
  self.CanAcceptDayNum = -1
  self.m_CheckinInfo = {}
end
function checkin:getCount()
  return self.m_CheckinCount
end
function checkin:getReCount()
  return self.m_ReCheckinCount
end
function checkin:getCanReCheckInDays()
  local cnt = 0
  for i = self.CanAcceptDayNum + 1, #self.m_CheckinInfo do
    if self.m_CheckinInfo[i] == CHECKINSTATUS_CANACCEPT then
      cnt = cnt + 1
    end
  end
  return cnt
end
function checkin:getCheckinStatus(daynum)
  return self.m_CheckinInfo[daynum]
end
function checkin:getIsCanAccept(daynum)
  print("self.CanAcceptDayNum == daynum:", self.CanAcceptDayNum == daynum, self.CanAcceptDayNum, daynum)
  if self.CanAcceptDayNum == daynum then
    local status = self:getCheckinStatus(daynum)
    if status == CHECKINSTATUS_CANACCEPT then
      return true
    elseif status == CHECKINSTATUS_BASEACCEPTED then
      local vipLv = g_LocalPlayer:getVipLv()
      local doubleVipLvNeed = 0
      local data = data_GiftOfCheckIn[daynum + 3000]
      if data then
        doubleVipLvNeed = data.vipLv
      end
      if doubleVipLvNeed == 0 then
        return false
      end
      if vipLv >= doubleVipLvNeed then
        return true
      else
        return false, doubleVipLvNeed, vipLv
      end
    end
  end
  return false
end
function checkin:dataUpdate(cnt, reCnt, detail, canCheckinId)
  if canCheckinId ~= nil then
    canCheckinId = canCheckinId or 0
    self.CanAcceptDayNum = canCheckinId - 3000
  end
  if cnt ~= nil then
    self.m_CheckinCount = cnt
  end
  if reCnt ~= nil then
    self.m_ReCheckinCount = reCnt
  end
  if detail ~= nil then
    self.m_CheckinInfo = {}
    for k, v in pairs(detail) do
      self.m_CheckinInfo[k] = v
    end
  end
  SendMessage(MsgID_Gift_CheckinRewardUpdate)
end
function checkin:CanTodayCheckIn()
  return self:getIsCanAccept(self.CanAcceptDayNum)
end
return checkin
