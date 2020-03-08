local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local AccumulativeLoginMgr = Lplus.Extend(AwardMgrBase, "AccumulativeLoginMgr")
local def = AccumulativeLoginMgr.define
local AwardUtils = require("Main.Award.AwardUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local CResult = {SUCCESS = 0}
def.const("table").CResult = CResult
def.field("table").state = nil
def.field("table").awardNoticeList = nil
local instance
def.static("=>", AccumulativeLoginMgr).Instance = function()
  if instance == nil then
    instance = AccumulativeLoginMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.state = {}
  self.state.loginDays = 0
  self.state.drawedDays = {}
  self.state.canDrawDaysList = {}
  self.awardNoticeList = {}
end
def.method("table").SyncLoginAward = function(self, data)
  self.state = {}
  self.state.loginDays = data.loginday
  self.state.drawedDays = {}
  for i, v in ipairs(data.awardedDays) do
    self.state.drawedDays[v] = true
  end
  self.state.canDrawDaysList = data.canAwardDays
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.ACCUMULATIVE_LOGIN_AWARD_UPDATE, nil)
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.UPDATE_LOGIN_DAYS, {
    data.loginday
  })
  self:Check2NoticeAward(data.item2num)
end
def.method("=>", "table").GetOverallAwardList = function(self)
  local cfgList = AwardUtils.GetOverallLoginAwardCfgList()
  local awardList = {}
  for i, cfg in ipairs(cfgList) do
    local awardData = {
      days = cfg.loginCount,
      items = {}
    }
    awardData.desc = cfg.desc
    for j, v in ipairs(cfg.items) do
      table.insert(awardData.items, {
        itemId = v.itemId,
        num = v.itemCount
      })
    end
    table.insert(awardList, awardData)
  end
  local sortfunction = function(left, right)
    return left.days < right.days
  end
  table.sort(awardList, sortfunction)
  return awardList
end
def.method("=>", "table").GetAccumulativeLoginState = function(self)
  return self.state
end
def.method("number", "=>", "boolean").IsDrawed = function(self, day)
  return self.state.drawedDays[day] and true or false
end
def.method("number", "=>", "boolean").CanDrawed = function(self, day)
  if self:IsDrawed(day) then
    return false
  end
  return day <= self.state.loginDays
end
def.method("number", "=>", "number").GetCanDrawedRemainDays = function(self, day)
  local remainDays = day - self.state.loginDays
  return remainDays
end
def.method("number").DrawLoginAward = function(self, days)
  self:C2S_GetLoginAwardReq(days)
end
def.method("=>", "boolean").IsHaveCanDrawAward = function(self)
  return #self.state.canDrawDaysList > 0
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:IsHaveCanDrawAward()
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  return #self.state.canDrawDaysList
end
def.override("=>", "boolean").IsOpen = function(self)
  local cfgList = AwardUtils.GetOverallLoginAwardCfgList()
  for i, cfg in ipairs(cfgList) do
    if self.state.drawedDays[cfg.loginCount] ~= true then
      return true
    end
  end
  return false
end
def.method("number", "table").RegisterAwardNotice = function(self, day, award)
end
def.method("table").Check2NoticeAward = function(self, item2num)
  AwardUtils.Check2NoticeAward(item2num)
end
def.method("number").C2S_GetLoginAwardReq = function(self, days)
  local p = require("netio.protocol.mzm.gsp.signaward.CGetLoginAwardReq").new(days)
  gmodule.network.sendProtocol(p)
  print(string.format("Send protocol (%s)[%d]", "netio.protocol.mzm.gsp.signaward.CGetLoginAwardReq", days))
end
return AccumulativeLoginMgr.Commit()
