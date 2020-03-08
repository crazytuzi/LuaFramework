local Lplus = require("Lplus")
local ItemModule = require("Main.Item.ItemModule")
local WishingWellUtils = require("Main.activity.WishingWell.WishingWellUtils")
local WishingWellData = Lplus.Class("WishingWellData")
local def = WishingWellData.define
local _instance
def.static("=>", WishingWellData).Instance = function()
  if _instance == nil then
    _instance = WishingWellData()
  end
  return _instance
end
def.field("table")._wishCountMap = nil
def.field("table")._wishingMap = nil
def.method().Reset = function(self)
  self._wishCountMap = nil
  self._wishingMap = nil
end
def.method("number", "number", "number").SetWishCount = function(self, type, count, wishTime)
  if WishingWellUtils.IsPastDay(wishTime) then
    warn("[WishingWellData:SetWishCount] new day! set count 0 for type:", type)
    count = 0
  end
  self:_DoSetWishCount(type, count)
end
def.method("number", "number")._DoSetWishCount = function(self, type, count)
  if nil == self._wishCountMap then
    self._wishCountMap = {}
  end
  if count ~= self._wishCountMap[type] then
    warn("[WishingWellData:_DoSetWishCount] SetWishCount:", count)
    self._wishCountMap[type] = count
    Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Wishing_Well_Change, {type = type, count = count})
  end
end
def.method("number", "=>", "number").GetWishCount = function(self, type)
  if nil == self._wishCountMap then
    self._wishCountMap = {}
    require("Main.activity.WishingWell.WishingWellProtocols").SendCGetBlessInfo(type)
  elseif nil == self._wishCountMap[type] then
    require("Main.activity.WishingWell.WishingWellProtocols").SendCGetBlessInfo(type)
  end
  return self._wishCountMap[type] or 0
end
def.method("number", "=>", "number").GetLeftFreeWishCount = function(self, type)
  local wishCount = self:GetWishCount(type)
  local freeCount = self:GetFreeWishCount(type)
  if wishCount < freeCount then
    return freeCount - wishCount
  else
    return 0
  end
end
def.method("number", "=>", "number").GetWishItemCount = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    return ItemModule.Instance():GetNumberByItemId(ItemModule.BAG, wishCfg.costItemId)
  else
    warn("[WishingWellData:GetWishItemCount] wishCfg nil for type:", type)
    return 0
  end
end
def.method().OnNewDay = function(self)
  if self._wishCountMap then
    for type, count in pairs(self._wishCountMap) do
      self:_DoSetWishCount(type, 0)
    end
  end
end
def.method("=>", "table").GetWishingMap = function(self)
  if nil == self._wishingMap then
    self:_LoadWishingCfgs()
  end
  return self._wishingMap
end
def.method()._LoadWishingCfgs = function(self)
  self._wishingMap = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_WISHINGWELL_CBlessCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local wishCfg = {}
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    wishCfg.type = DynamicRecord.GetIntValue(entry, "id")
    wishCfg.npcController = DynamicRecord.GetIntValue(entry, "npcController")
    wishCfg.npcId = DynamicRecord.GetIntValue(entry, "npcCfgid")
    wishCfg.serviceId = DynamicRecord.GetIntValue(entry, "npcServiceCfgid")
    wishCfg.freeNum = DynamicRecord.GetIntValue(entry, "freeNum")
    wishCfg.maxNum = DynamicRecord.GetIntValue(entry, "maxNum")
    wishCfg.awardId = DynamicRecord.GetIntValue(entry, "awardCfgid")
    wishCfg.awardItemList = WishingWellUtils.GetAwardItems(wishCfg.awardId)
    wishCfg.costItemId = DynamicRecord.GetIntValue(entry, "itemCfgid")
    wishCfg.costItemNum = DynamicRecord.GetIntValue(entry, "itemNum")
    wishCfg.titleTexId = DynamicRecord.GetIntValue(entry, "titleSource")
    wishCfg.wellTexId = DynamicRecord.GetIntValue(entry, "blessSource")
    wishCfg.tipId = DynamicRecord.GetIntValue(entry, "tipCfgid")
    wishCfg.wishEffectId = DynamicRecord.GetIntValue(entry, "hitEffectCfgid")
    wishCfg.poolEffectId = DynamicRecord.GetIntValue(entry, "effectCfgid")
    wishCfg.effectDuration = DynamicRecord.GetFloatValue(entry, "effectTime")
    self._wishingMap[wishCfg.type] = wishCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("number", "=>", "table").GetWishingCfgByType = function(self, type)
  return self:GetWishingMap()[type]
end
def.method("number", "=>", "number").GetFreeWishCount = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    return wishCfg.freeNum
  else
    warn("[WishingWellData:GetFreeWishCount] wishCfg nil for type:", type)
    return 0
  end
end
def.method("number", "=>", "number").GetMaxWishCount = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    return wishCfg.maxNum
  else
    warn("[WishingWellData:GetMaxWishCount] wishCfg nil for type:", type)
    return 0
  end
end
def.method("number", "=>", "number").GetNpcId = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    return wishCfg.npcId
  else
    warn("[WishingWellData:GetNpcId] wishCfg nil for type:", type)
    return 0
  end
end
def.method("number", "=>", "number").GetTypeByServiceId = function(self, serviceId)
  local result = 0
  for type, wishCfg in pairs(self:GetWishingMap()) do
    if wishCfg.serviceId == serviceId then
      result = type
      break
    end
  end
  return result
end
def.method("number", "=>", "number").GetCostItemId = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    return wishCfg.costItemId
  else
    warn("[WishingWellData:GetCostItemId] wishCfg nil for type:", type)
    return 0
  end
end
def.method("number", "=>", "number").GetCostItemNum = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    return wishCfg.costItemNum
  else
    warn("[WishingWellData:GetCostItemNum] wishCfg nil for type:", type)
    return 0
  end
end
def.method("number", "=>", "number").GetTipId = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    return wishCfg.tipId
  else
    warn("[WishingWellData:GetTipId] wishCfg nil for type:", type)
    return 0
  end
end
def.method("number", "=>", "string").GetWishEffectRes = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    local effectCfg = GetEffectRes(wishCfg.wishEffectId)
    if nil == effectCfg then
      warn("[WishingWellData:GetWishEffectRes] effectCfg nil for type:", type)
      return nil
    else
      return effectCfg.path
    end
  else
    warn("[WishingWellData:GetWishEffectRes] wishCfg nil for type:", type)
    return nil
  end
end
def.method("number", "=>", "string").GetPoolEffectRes = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    local effectCfg = GetEffectRes(wishCfg.poolEffectId)
    if nil == effectCfg then
      warn("[WishingWellData:GetPoolEffectRes] effectCfg nil for type:", type)
      return nil
    else
      return effectCfg.path
    end
  else
    warn("[WishingWellData:GetPoolEffectRes] wishCfg nil for type:", type)
    return nil
  end
end
def.method("number", "=>", "number").GetWishEffectDuration = function(self, type)
  local wishCfg = self:GetWishingCfgByType(type)
  if wishCfg then
    return wishCfg.effectDuration or 0
  else
    warn("[WishingWellData:GetWishEffectDuration] wishCfg nil for type:", type)
    return 0
  end
end
WishingWellData.Commit()
return WishingWellData
