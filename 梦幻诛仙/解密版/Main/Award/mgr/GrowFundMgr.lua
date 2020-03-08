local Lplus = require("Lplus")
local AwardMgrBase = require("Main.Award.mgr.AwardMgrBase")
local GrowFundMgr = Lplus.Extend(AwardMgrBase, "GrowFundMgr")
local def = GrowFundMgr.define
local AwardUtils = require("Main.Award.AwardUtils")
local ItemModule = require("Main.Item.ItemModule")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local CResult = {SUCCESS = 0}
def.const("table").CResult = CResult
def.const("number").GrowFundActivityId = constant.CQingfuCfgConsts.LEVEL_GROWTH_FUN_ACTIVITY_CFG_ID1
GrowFundMgr.StrongerFundActivityId = constant.CQingfuCfgConsts.LEVEL_GROWTH_FUN_ACTIVITY_CFG_ID2
GrowFundMgr.StrongerFundSwitchId = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_ADVANCED_LEVEL_GROWTH_FUND
def.field("table").growFundInfo = nil
def.field("boolean").hasNotifyMessage = false
def.field("table").fillInfo = nil
def.field("number").num = 0
def.field("boolean").allget = false
local instance
def.static("=>", GrowFundMgr).Instance = function()
  if instance == nil then
    instance = GrowFundMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, GrowFundMgr.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, GrowFundMgr.OnLeaveWorld)
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  if instance then
    instance.growFundInfo = nil
    instance.hasNotifyMessage = false
    instance.fillInfo = nil
    instance.num = 0
    instance.allget = false
  end
end
def.static("table", "table").OnFunctionOpenChange = function(p1, p2)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if p1.feature == ModuleFunSwitchInfo.TYPE_LEVEL_GROWTH_FUND or p1.feature == GrowFundMgr.StrongerFundSwitchId then
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.GROW_FUND_AWARD_UPDATE, nil)
  end
end
def.method("table").SyncGrowFund = function(self, data)
  self.growFundInfo = data.activity_infos
  self:updateFillInfo()
  self:setStrongerFundActivityId()
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.GROW_FUND_AWARD_UPDATE, nil)
end
def.method("number").SyncHeroLevel = function(self, heroLevel)
  if heroLevel < 25 then
    return
  end
  self:updateFillInfo()
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.GROW_FUND_AWARD_UPDATE, nil)
end
def.method("table").updateGrowFund = function(self, info)
  if self.growFundInfo == nil then
    return
  end
  if self.growFundInfo[info.activity_id] then
    self.growFundInfo[info.activity_id].sortid = info.sortid
  end
  Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.GROW_FUND_AWARD_UPDATE, nil)
end
def.method().updateFillInfo = function(self)
  if self.growFundInfo == nil then
    return
  end
  self.fillInfo = {}
  self.num = 0
  self.allget = true
  self.hasNotifyMessage = false
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GROW_FUND_CFG)
  if entries == nil then
    return
  end
  DynamicDataTable.FastGetRecordBegin(entries)
  local prop = require("Main.Hero.Interface").GetHeroProp()
  if prop == nil then
    return
  end
  local mylevel = prop.level
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  local idx = 1
  local fillInfo = self.fillInfo
  for k, v in pairs(self.growFundInfo) do
    local a = {}
    a.sortid = v.sortid
    a.purchased = v.purchased
    a.items = {}
    fillInfo[idx] = a
    for i = 1, recordCount do
      local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
      if record:GetIntValue("activity_cfg_id") == k then
        local r = {}
        r.award_id = record:GetIntValue("award_cfg_id")
        r.name = record:GetStringValue("name")
        r.desc = record:GetStringValue("desc")
        r.level_cond = record:GetIntValue("level_cond")
        r.sortid = record:GetIntValue("sort_id")
        r.id = record:GetIntValue("id")
        r.serviceId = record:GetIntValue("serviceId")
        a.items[i] = r
        self.num = self.num + 1
        if r.sortid > v.sortid then
          self.allget = false
        end
        if mylevel >= r.level_cond and 0 < v.purchased and r.sortid > v.sortid then
          self.hasNotifyMessage = true
        end
      end
    end
    idx = idx + 1
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.static("number", "=>", "table").GetGrowFundCfgByActivityId = function(activityId)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GROW_FUND_CFG)
  if entries == nil then
    return
  end
  local cfgs = {}
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    if record:GetIntValue("activity_cfg_id") == activityId then
      local r = {}
      r.award_id = record:GetIntValue("award_cfg_id")
      r.name = record:GetStringValue("name")
      r.desc = record:GetStringValue("desc")
      r.level_cond = record:GetIntValue("level_cond")
      r.sortid = record:GetIntValue("sort_id")
      r.id = record:GetIntValue("id")
      r.serviceId = record:GetIntValue("serviceId")
      r.banner = record:GetIntValue("banner")
      table.insert(cfgs, r)
    end
  end
  return cfgs
end
def.method("number", "=>", "boolean").isGetAllAward = function(self, activityId)
  local growFundInfo = self:GetGrowFundInfoByActivityId(activityId)
  if growFundInfo == nil then
    return false
  end
  local growFundCfgs = GrowFundMgr.GetGrowFundCfgByActivityId(activityId)
  local isAllGet = true
  for i, v in ipairs(growFundCfgs) do
    if v.sortid > growFundInfo.sortid then
      isAllGet = false
      break
    end
  end
  return isAllGet
end
def.method("=>", "table").GetGrowFundInfo = function(self)
  self:updateFillInfo()
  return self.growFundInfo
end
def.method("number", "=>", "table").GetGrowFundInfoByActivityId = function(self, activityId)
  if self.growFundInfo == nil then
    return nil
  end
  return self.growFundInfo[activityId] or {purchased = 0, sortid = 0}
end
def.method("number", "=>", "boolean").CanGetFundAward = function(self, activityId)
  local growFundInfo = self:GetGrowFundInfoByActivityId(activityId)
  if growFundInfo == nil then
    return false
  end
  local prop = require("Main.Hero.Interface").GetHeroProp()
  if prop == nil then
    return
  end
  local mylevel = prop.level
  local growFundCfgs = GrowFundMgr.GetGrowFundCfgByActivityId(activityId)
  for _, v in ipairs(growFundCfgs) do
    if mylevel >= v.level_cond and growFundInfo.purchased > 0 and v.sortid > growFundInfo.sortid then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").IsHaveGrowFundNotifyMessage = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LEVEL_GROWTH_FUND) then
    return false
  end
  return self:CanGetFundAward(GrowFundMgr.GrowFundActivityId)
end
def.method("=>", "boolean").IsHaveStrongerFundNotifyMessage = function(self)
  if not IsFeatureOpen(GrowFundMgr.StrongerFundSwitchId) then
    return false
  end
  return self:CanGetFundAward(GrowFundMgr.StrongerFundActivityId)
end
def.override("=>", "boolean").IsHaveNotifyMessage = function(self)
  return self:IsHaveGrowFundNotifyMessage() or self:IsHaveStrongerFundNotifyMessage()
end
def.override("=>", "number").GetNotifyMessageCount = function(self)
  local l = self:IsHaveNotifyMessage() and 1 or 0
  return self:IsHaveNotifyMessage() and 1 or 0
end
def.method("=>", "boolean").GrowFundIsOpen = function(self)
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_LEVEL_GROWTH_FUND) then
    return false
  end
  local loginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
  local isFakePlatform = loginModule:IsFakeLoginPlatform()
  if isFakePlatform then
    local info = GrowFundMgr.Instance():GetGrowFundInfoByActivityId(GrowFundMgr.GrowFundActivityId)
    if info == nil or info.purchased ~= 1 then
      return false
    end
  end
  if self.growFundInfo == nil then
    return false
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp.level >= _G.constant.CQingfuCfgConsts.LEVEL_GROWTH_FUND_ENABLE_NEED_ROLE_LEVEL and not self:isGetAllAward(GrowFundMgr.GrowFundActivityId) then
    return true
  end
  return false
end
def.method("=>", "boolean").StrongerFundIsOpen = function(self)
  if not IsFeatureOpen(GrowFundMgr.StrongerFundSwitchId) then
    return false
  end
  local loginModule = gmodule.moduleMgr:GetModule(ModuleId.LOGIN)
  local isFakePlatform = loginModule:IsFakeLoginPlatform()
  if isFakePlatform then
    local info = GrowFundMgr.Instance():GetGrowFundInfoByActivityId(GrowFundMgr.StrongerFundActivityId)
    if info == nil or info.purchased ~= 1 then
      return false
    end
  end
  if self:GrowFundIsOpen() then
    return false
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  local activityId = GrowFundMgr.StrongerFundActivityId
  if activityInterface:isAchieveActivityLevel(activityId) and activityInterface:isActivityOpend(activityId) and not self:isGetAllAward(activityId) then
    return true
  end
  return false
end
def.override("=>", "boolean").IsOpen = function(self)
  return self:GrowFundIsOpen() or self:StrongerFundIsOpen()
end
def.method().setStrongerFundActivityId = function(self)
  local entries = DynamicData.GetTable(CFG_PATH.DATA_GROW_FUND_CFG)
  if entries == nil then
    return
  end
  local cfgs = {}
  local recordCount = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  local firstGrowFundActivityId = GrowFundMgr.GrowFundActivityId
  for i = 1, recordCount do
    local record = DynamicDataTable.FastGetRecordByIdx(entries, i - 1)
    local activityId = record:GetIntValue("activity_cfg_id")
    if activityId ~= firstGrowFundActivityId then
      local r = {}
      r.activityId = activityId
      r.level_cond = record:GetIntValue("level_cond")
      r.switchid = record:GetIntValue("switchid")
      table.insert(cfgs, r)
    end
  end
  table.sort(cfgs, function(info1, info2)
    return info1.level_cond <= info2.level_cond
  end)
  for i, v in ipairs(cfgs) do
    GrowFundMgr.StrongerFundActivityId = v.activityId
    GrowFundMgr.StrongerFundSwitchId = v.switchid
    if not self:isGetAllAward(v.activityId) then
      break
    end
  end
  warn("---->>>>>setStrongerFundActivityId:", GrowFundMgr.StrongerFundActivityId, GrowFundMgr.StrongerFundSwitchId)
end
def.method("=>", "string").GetStrongerFundName = function(self)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityCfg = ActivityInterface.GetActivityCfgById(GrowFundMgr.StrongerFundActivityId)
  if activityCfg then
    return activityCfg.activityName
  end
  return textRes.Award[300]
end
return GrowFundMgr.Commit()
