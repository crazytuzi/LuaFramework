local event = class("EventMgr")
event.Status_CannotRecive = 1
event.Status_CanRecive = 2
event.Status_HadRecive = 3
function event:ctor()
  self.m_Event = {}
  self.m_YueKaTimeEndTime = 0
end
function event:reset()
  self.m_Event = {}
  self.m_YueKaTimeEndTime = 0
  SendMessage(MsgID_Activity_Updated)
end
function event:getAllEvent()
  return self.m_Event
end
function event:canReciveEvent()
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_Huodong)
  if openFlag == false then
    return false
  end
  local canRecive = false
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local zs = g_LocalPlayer:getObjProperty(1, PROPERTY_ZHUANSHENG)
  for eventId, eventData in pairs(self.m_Event) do
    local data = data_DailyHuodongAward[eventId]
    if data and data_judgeFuncOpen(zs, lv, data.OpenZs, data.OpenLv, data.AlwaysJudgeLvFlag) and eventData.state == activity.event.Status_CanRecive then
      canRecive = true
      return canRecive
    end
  end
  return canRecive
end
function event:getTodayEvent_TBSJ_YZDD()
  local tbsjFlag = false
  local yzddFlag = false
  local xzscFlag = false
  local ltzbFlag = false
  for eventId, eventData in pairs(self.m_Event) do
    if eventId == 11003 then
      if eventData.state == activity.event.Status_CanRecive or eventData.state == activity.event.Status_CannotRecive then
        tbsjFlag = true
      end
    elseif eventId == 11004 then
      if eventData.state == activity.event.Status_CanRecive or eventData.state == activity.event.Status_CannotRecive then
        yzddFlag = true
      end
    elseif eventId == 11006 then
      if eventData.state == activity.event.Status_CanRecive or eventData.state == activity.event.Status_CannotRecive then
        xzscFlag = true
      end
    elseif eventId == 11001 and (eventData.state == activity.event.Status_CanRecive or eventData.state == activity.event.Status_CannotRecive) then
      ltzbFlag = true
    end
  end
  return tbsjFlag, yzddFlag, xzscFlag, ltzbFlag
end
function event:reqReciveAward(eventId)
  netsend.netactivity.reqReciveAward(eventId)
end
function event:getEventReward(eventId)
  local data = data_DailyHuodongAward[eventId]
  local awardList = {}
  local award = data.Award or {}
  if award.Tili > 0 then
    awardList[#awardList + 1] = {
      RESTYPE_TILI,
      award.Tili
    }
  end
  if 0 < award.Gold then
    awardList[#awardList + 1] = {
      RESTYPE_GOLD,
      award.Gold
    }
  end
  if 0 < award.Coin then
    awardList[#awardList + 1] = {
      RESTYPE_COIN,
      award.Coin
    }
  end
  if award.Silver ~= nil and 0 < award.Silver then
    awardList[#awardList + 1] = {
      RESTYPE_SILVER,
      award.Silver
    }
  end
  if award.Huoli ~= nil and 0 < award.Huoli then
    awardList[#awardList + 1] = {
      RESTYPE_HUOLI,
      award.Huoli
    }
  end
  if award.BaoShiDu ~= nil and 0 < award.BaoShiDu then
    awardList[#awardList + 1] = {
      RESTYPE_BAOSHIDU,
      award.BaoShiDu
    }
  end
  if award.Item then
    for oId, num in pairs(award.Item) do
      awardList[#awardList + 1] = {oId, num}
    end
  end
  return awardList
end
function event:reciveResult(eventId, result)
  if eventId == nil or result == nil then
    return
  end
  if result == 0 then
  elseif result == 1 then
  elseif result == 2 then
  end
end
function event:update(param)
  if param == nil then
    return
  end
  local eventId = param.hid
  local data = param.data
  if eventId == nil or data == nil then
    return
  end
  local bonus_state = data.bonus_state
  local progress = data.progress
  self.m_Event[eventId] = {state = bonus_state, progress = progress}
  if g_DataMgr:getIsSendFinished() == true then
    SendMessage(MsgID_Activity_Updated)
  end
end
function event:setYueKaEndTime(restTime)
  self.m_YueKaTimeEndTime = os.time() + restTime
end
function event:getYueKaEndTime()
  return self.m_YueKaTimeEndTime
end
return event
