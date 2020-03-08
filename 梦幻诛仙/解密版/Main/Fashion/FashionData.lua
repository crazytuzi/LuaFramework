local Lplus = require("Lplus")
local FashionData = Lplus.Class("FashionData")
local FashionUtils = require("Main.Fashion.FashionUtils")
local FashionDressConst = require("netio.protocol.mzm.gsp.fashiondress.FashionDressConst")
local def = FashionData.define
local instance
def.field("number").currentFashionId = FashionDressConst.NO_FASHION_DRESS
def.field("table").haveFashionInfo = nil
def.field("table").activatePropertyList = nil
def.field("boolean")._hasEffectNotify = false
def.field("table").unlockedThemeFashions = nil
def.static("=>", FashionData).Instance = function()
  if instance == nil then
    instance = FashionData()
  end
  return instance
end
def.method().ClearData = function(self)
  self.currentFashionId = FashionDressConst.NO_FASHION_DRESS
  self.haveFashionInfo = nil
  self.activatePropertyList = nil
  self._hasEffectNotify = false
  self.unlockedThemeFashions = nil
end
def.method("table").SyncFashionDressInfo = function(self, p)
  self.currentFashionId = p.currentFashionDressCfgId
  self.haveFashionInfo = p.fashionDressInfoMap
  self.activatePropertyList = p.activatePropertyList
end
def.method("number").UnlockFashionDress = function(self, id)
  local item = FashionUtils.GetFashionItemDataById(id)
  if item.effectTime == FashionDressConst.FOREVER then
    self.haveFashionInfo[id] = Int64.new(FashionDressConst.FOREVER)
  else
    local oneHour = 3600
    self.haveFashionInfo[id] = Int64.new(item.effectTime * oneHour)
  end
end
def.method("number").PutOnFashionDress = function(self, id)
  self.currentFashionId = id
end
def.method("number").PutOffFashionDress = function(self, id)
  if self.currentFashionId == id then
    self.currentFashionId = FashionDressConst.NO_FASHION_DRESS
  else
    warn(string.format("\229\141\184\228\184\139\231\154\132\230\151\182\232\163\133id[%d]\229\146\140\230\156\172\232\186\171id[%d]\228\184\141\231\172\166", id, self.currentFashionId))
  end
end
def.method("number").ActiveProperty = function(self, id)
  local isHave = false
  for idx, cfgId in pairs(self.activatePropertyList) do
    if cfgId == id then
      isHave = true
      break
    end
  end
  if not isHave then
    table.insert(self.activatePropertyList, id)
  else
    warn(string.format("\229\177\158\230\128\167id[%d]\233\135\141\229\164\141\230\191\128\230\180\187", id))
  end
end
def.method("number").DeActiveProperty = function(self, id)
  for idx, cfgId in pairs(self.activatePropertyList) do
    if cfgId == id then
      table.remove(self.activatePropertyList, idx)
      break
    end
  end
end
def.method("number").SetFashionExpired = function(self, id)
  for idx, cfgId in pairs(self.activatePropertyList) do
    if cfgId == id then
      table.remove(self.activatePropertyList, idx)
      break
    end
  end
  if self.currentFashionId == id then
    self.currentFashionId = FashionDressConst.NO_FASHION_DRESS
  end
  self.haveFashionInfo[id] = nil
end
def.method("number", "=>", "boolean").IsSameWithCurrentFashion = function(self, id)
  if self.currentFashionId == id then
    return true
  end
  return false
end
def.method("=>", "number").GetCurrentActivePropertyCount = function(self)
  return #self.activatePropertyList
end
def.method().ReduceFashionLeftTime = function(self)
  if self.haveFashionInfo == nil then
    return
  end
  local oneMinute = 60
  for cfgId, leftTime in pairs(self.haveFashionInfo) do
    if not Int64.eq(self.haveFashionInfo[cfgId], FashionDressConst.FOREVER) and Int64.lt(oneMinute, self.haveFashionInfo[cfgId]) then
      self.haveFashionInfo[cfgId] = leftTime - oneMinute
    end
  end
end
def.method("=>", "boolean").IsEquipFashion = function(self)
  return self.currentFashionId ~= FashionDressConst.NO_FASHION_DRESS
end
def.method().AddNewEffectNotify = function(self)
  self._hasEffectNotify = true
end
def.method("=>", "boolean").HasEffectNotify = function(self)
  return self._hasEffectNotify
end
def.method().ClearEffectNotify = function(self)
  self._hasEffectNotify = false
end
def.method("=>", "table").GetCurrentFashionEffects = function(self)
  local effects = {}
  for id, leftTime in pairs(self.haveFashionInfo) do
    local fashionItem = FashionUtils.GetFashionItemDataById(id)
    local skillEffects = fashionItem.effects
    for i = 1, #skillEffects do
      local skillId = skillEffects[i]
      table.insert(effects, skillId)
    end
  end
  return effects
end
def.method("table").SyncThemeFashionDressInfo = function(self, p)
  self.unlockedThemeFashions = {}
  for k, v in pairs(p.unlock_theme_fashion_dress_type_id_set) do
    self.unlockedThemeFashions[k] = k
  end
end
def.method("table").SyncThemeFashionDressUpdateInfo = function(self, p)
  if self.unlockedThemeFashions == nil then
    return
  end
  for k, v in pairs(p.add_set) do
    self.unlockedThemeFashions[k] = k
  end
  for k, v in pairs(p.delete_set) do
    self.unlockedThemeFashions[k] = nil
  end
end
def.method("number", "=>", "boolean").IsThemeFashionUnlock = function(self, typeId)
  if self.unlockedThemeFashions == nil then
    return false
  end
  return self.unlockedThemeFashions[typeId] ~= nil
end
def.method("=>", "table").GetThemeFashionUnlockStatus = function(self)
  local themeFashionCfgData = FashionUtils.GetAllThemeFashionCfgData()
  local status = {}
  for i = 1, #themeFashionCfgData do
    local themeFashion = themeFashionCfgData[i]
    local curUnlockNum = 0
    local totalNum = #themeFashion.relatedFashionType
    for j = 1, totalNum do
      local fashionType = themeFashion.relatedFashionType[j]
      if FashionData.Instance():IsThemeFashionUnlock(fashionType) then
        curUnlockNum = curUnlockNum + 1
      end
    end
    local themeFashionStatus = {}
    themeFashionStatus.id = themeFashion.id
    themeFashionStatus.isFullUnlock = totalNum <= curUnlockNum
    themeFashionStatus.unlockNum = curUnlockNum
    themeFashionStatus.awardIndex = 0
    local awards = FashionUtils.GetTheFashionAwardById(themeFashion.id)
    for k = #awards, 1, -1 do
      if curUnlockNum >= awards[k].unlockFashionNum then
        themeFashionStatus.awardIndex = k
        break
      end
    end
    status[themeFashion.id] = themeFashionStatus
  end
  return status
end
FashionData.Commit()
return FashionData
