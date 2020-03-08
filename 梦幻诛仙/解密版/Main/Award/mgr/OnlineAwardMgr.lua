local Lplus = require("Lplus")
local AwardUtils = require("Main.Award.AwardUtils")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local OnlineAwardMgr = Lplus.Extend(AwardMgrBase, "OnlineAwardMgr")
local def = OnlineAwardMgr.define
local CResult = {SUCCESS = 0}
def.const("table").CResult = CResult
def.field("table").state = nil
def.field("table").awardNoticeList = nil
local instance
def.static("=>", OnlineAwardMgr).Instance = function()
  if instance == nil then
    instance = OnlineAwardMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.state = {}
  self.state.onlineTime = 0
  self.state.lastSyncTime = 0
  self.state.drawedTimes = {}
  self.awardNoticeList = {}
end
def.method("table").SyncOnlineAward = function(self, data)
  self.state.drawedTimes = {}
  for i, _time in ipairs(data.awardedTimes) do
    self.state.drawedTimes[_time] = true
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.ONLINE_AWARD_UPDATE, nil)
  self:NoticeAward(data.item2num)
end
def.method("table").SyncOnlineTime = function(self, data)
  self.state.onlineTime = data.onlinetime
  self.state.lastSyncTime = GetServerTime()
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.ONLINE_TIME_UPDATE, nil)
end
def.method("=>", "number").GetCurrentOnlineTime = function(self)
  return self.state.onlineTime + GetServerTime() - self.state.lastSyncTime
end
def.method("=>", "table").GetOverallAwardList = function(self)
  local cfgs = AwardUtils.GetOverallOnlineAwardCfgList()
  local awardList = {}
  for i, cfg in ipairs(cfgs) do
    local awardData = {
      time = cfg.time,
      items = {}
    }
    for j, v in ipairs(cfg.items) do
      table.insert(awardData.items, {
        itemId = v.itemId,
        num = v.itemCount
      })
    end
    table.insert(awardList, awardData)
  end
  local sortfunction = function(left, right)
    return left.time < right.time
  end
  table.sort(awardList, sortfunction)
  return awardList
end
def.method("=>", "table").GetOnlineAwardState = function(self)
  return self.state
end
def.method("number", "=>", "boolean").IsDrawed = function(self, time)
  return self.state.drawedTimes[time] and true or false
end
def.method("number", "=>", "boolean").CanDrawed = function(self, time)
  if self:IsDrawed(time) then
    return false
  end
  return time <= self.state.onlineTime
end
def.method("=>", "boolean").IsHaveCanDrawAward = function(self)
  local cfgs = AwardUtils.GetOverallOnlineAwardCfgList()
  if not cfgs then
    return false
  end
  for i, cfg in ipairs(cfgs) do
    if self.state.onlineTime >= cfg.time and self.state.drawedTimes[cfg.time] ~= true then
      return true
    end
  end
  return false
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:IsHaveCanDrawAward()
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  return self:IsHaveNotifyMessage() and 1 or 0
end
def.override("=>", "boolean").IsOpen = function(self)
  local cfgs = AwardUtils.GetOverallOnlineAwardCfgList()
  if not cfgs then
    return true
  end
  for i, cfg in ipairs(cfgs) do
    if self.state.drawedTimes[cfg.time] ~= true then
      return true
    end
  end
  return false
end
def.method("number").DrawOnlineAward = function(self, time)
  self:C2S_GetOnlineAwardReq(time)
end
def.method("table").NoticeAward = function(self, data)
  if not data then
    return
  end
  local awards = {}
  awards.items = {}
  for id, num in pairs(data) do
    local award = {}
    award.itemId = id
    award.num = num
    table.insert(awards.items, award)
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.DRAW_AWARD_MESSAGE, awards)
end
def.method("number").C2S_GetOnlineAwardReq = function(self, time)
  print("Sent Draw Online Award Protocol..." .. time)
  local p = require("netio.protocol.mzm.gsp.signaward.CGetOnlineAwardReq").new(time)
  gmodule.network.sendProtocol(p)
end
return OnlineAwardMgr.Commit()
