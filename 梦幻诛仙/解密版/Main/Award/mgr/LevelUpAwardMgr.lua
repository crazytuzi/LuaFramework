local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local LevelUpAwardMgr = Lplus.Extend(AwardMgrBase, "LevelUpAwardMgr")
local def = LevelUpAwardMgr.define
local AwardUtils = require("Main.Award.AwardUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local CResult = {SUCCESS = 0}
def.const("table").CResult = CResult
def.field("table").state = nil
def.field("table").awardNoticeList = nil
local instance
def.static("=>", LevelUpAwardMgr).Instance = function()
  if instance == nil then
    instance = LevelUpAwardMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self.state = {}
  self.state.roleLevel = 0
  self.state.drawedLevels = {}
  self.awardNoticeList = {}
end
def.method("table").SyncLevelUpAward = function(self, data)
  self.state.drawedLevels = {}
  for i, level in ipairs(data.awardedLevels) do
    self.state.drawedLevels[level] = true
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.LEVEL_UP_AWARD_UPDATE, nil)
  self:Check2NoticeAward(data.item2num)
end
def.method("number").SyncHeroLevel = function(self, heroLevel)
  if heroLevel == self.state.roleLevel then
    return
  end
  self.state.roleLevel = heroLevel
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.LEVEL_UP_AWARD_UPDATE, nil)
end
def.method("=>", "table").GetOverallAwardList = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return nil
  end
  local cfgs = AwardUtils.GetOverallLevelUpAwardCfgList(heroProp.occupation, heroProp.gender)
  local awardList = {}
  for i, cfg in ipairs(cfgs) do
    local awardData = {
      level = cfg.level,
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
    return left.level < right.level
  end
  table.sort(awardList, sortfunction)
  return awardList
end
def.method("=>", "table").GetLevelUpAwardState = function(self)
  return self.state
end
def.method("number", "=>", "boolean").IsDrawed = function(self, level)
  return self.state.drawedLevels[level] and true or false
end
def.method("number", "=>", "boolean").CanDrawed = function(self, level)
  if self:IsDrawed(level) then
    return false
  end
  return level <= _G.GetHeroProp().level
end
def.method("=>", "boolean").IsHaveCanDrawAward = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local cfgs = AwardUtils.GetOverallLevelUpAwardCfgList(heroProp.occupation, heroProp.gender)
  for i, cfg in ipairs(cfgs) do
    if heroProp.level >= cfg.level and self.state.drawedLevels[cfg.level] ~= true then
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
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local cfgs = AwardUtils.GetOverallLevelUpAwardCfgList(heroProp.occupation, heroProp.gender)
  for i, cfg in ipairs(cfgs) do
    if self.state.drawedLevels[cfg.level] ~= true then
      return true
    end
  end
  return false
end
def.method("number").DrawLevelUpAward = function(self, level)
  self:C2S_GetLevelAwardReq(level)
end
def.method("number", "table").RegisterAwardNotice = function(self, level, award)
end
def.method("table").Check2NoticeAward = function(self, item2num)
  AwardUtils.Check2NoticeAward(item2num)
end
def.method("number").C2S_GetLevelAwardReq = function(self, level)
  local p = require("netio.protocol.mzm.gsp.signaward.CGetLevelAwardReq").new(level)
  gmodule.network.sendProtocol(p)
  print(string.format("Send protocol (%s)[%d]", "netio.protocol.mzm.gsp.signaward.CGetLevelAwardReq", level))
end
return LevelUpAwardMgr.Commit()
