local Lplus = require("Lplus")
local ItemModule = require("Main.Item.ItemModule")
local RunningXuanGongData = Lplus.Class("RunningXuanGongData")
local def = RunningXuanGongData.define
local instance
def.static("=>", RunningXuanGongData).Instance = function()
  if instance == nil then
    instance = RunningXuanGongData()
  end
  return instance
end
def.field("table")._cfgData = nil
def.method().InitData = function(self)
  local TaskRunningXuanGong = require("Main.Soaring.proxy.TaskRunningXuanGong")
  local record = DynamicData.GetRecord(CFG_PATH.DATA_RUNNINGXUANGONG, TaskRunningXuanGong.ACTIVITY_ID)
  if record == nil then
    warn("[RunningXuanGongData:InitData] Load ancient seal data error, actCfgId = ", TaskRunningXuanGong.ACTIVITY_ID)
    return
  end
  self._cfgData = {}
  self._cfgData.activity_cfg_id = record:GetIntValue("activity_cfg_id")
  self._cfgData.moduleid = record:GetIntValue("moduleid")
  self._cfgData.npc_id = record:GetIntValue("npc_id")
  self._cfgData.get_item_npc_service_id = record:GetIntValue("get_item_npc_service_id")
  self._cfgData.commit_item_npc_service_id = record:GetIntValue("commit_item_npc_service_id")
  self._cfgData.item_cfg_id = record:GetIntValue("item_cfg_id")
  self._cfgData.extra_type = record:GetIntValue("extra_type")
  self._cfgData.extra_value = record:GetIntValue("extra_value")
  self._cfgData.add_extra_value_per_operation = record:GetIntValue("add_extra_value_per_operation")
  self._cfgData.effect_id = record:GetIntValue("effect_id")
  self._cfgData.effect_coord_x = record:GetIntValue("effect_coord_x")
  self._cfgData.effect_coord_y = record:GetIntValue("effect_coord_y")
  self._cfgData.desc = record:GetStringValue("desc")
end
def.method("=>", "table").GetCfg = function(self)
  if nil == self._cfgData then
    self:InitData()
  end
  return self._cfgData
end
def.method("=>", "number").GetNPCId = function(self)
  return self:GetCfg() and self:GetCfg().npc_id or 0
end
def.method("=>", "number").GetItemId = function(self)
  return self:GetCfg() and self:GetCfg().item_cfg_id or 0
end
def.method("=>", "table").GetItemInfo = function(self)
  local itemKey, itemInfo = ItemModule.Instance():SelectOneItemByItemId(ItemModule.BAG, self:GetItemId())
  return itemInfo
end
def.method("=>", "number").GetItemKey = function(self)
  local result = -1
  local item = self:GetItemInfo()
  if item then
    result = item.itemKey
  end
  return result
end
def.method("=>", "number").GetCurrentExp = function(self)
  local result = 0
  local itemInfo = self:GetItemInfo()
  if itemInfo then
    local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
    result = itemInfo.extraMap[ItemXStoreType.EXPERIENCE_VALUE]
    warn("[RunningXuanGongData:GetCurrentExp] get item exp:", result)
  else
    warn("[RunningXuanGongData:GetCurrentExp] iteminfo nil for itemid:", self:GetItemId())
  end
  return result
end
def.method("=>", "number").GetFullExp = function(self)
  return self:GetCfg() and self:GetCfg().extra_value or 0
end
def.method("=>", "number").GetExpRate = function(self)
  local rate = 0
  local fullexp = self:GetFullExp()
  if fullexp > 0 then
    rate = self:GetCurrentExp() / fullexp
  end
  rate = math.max(0, rate)
  rate = math.min(1, rate)
  return rate
end
def.method("=>", "number").GetExpPerOperation = function(self)
  return self:GetCfg() and self:GetCfg().add_extra_value_per_operation or 0
end
def.method("=>", "number").GetServiceIdFetchItem = function(self)
  return self:GetCfg() and self:GetCfg().get_item_npc_service_id or 0
end
def.method("=>", "number").GetServiceIdCommitItem = function(self)
  return self:GetCfg() and self:GetCfg().commit_item_npc_service_id or 0
end
def.method("=>", "table").GetEffectInfo = function(self)
  return self:GetCfg() and {
    effectId = self:GetCfg().effect_id,
    x = self:GetCfg().effect_coord_x,
    y = self:GetCfg().effect_coord_y
  }
end
def.method("=>", "boolean").HasItem = function(self)
  return self:GetItemInfo() ~= nil
end
def.method("=>", "string").GetTalkContent = function(self)
  return self:GetCfg() and self:GetCfg().desc or ""
end
def.method().Release = function(self)
  self._cfgData = nil
end
def.method("=>", "boolean").IsNil = function(self)
  return self._cfgData == nil
end
return RunningXuanGongData.Commit()
