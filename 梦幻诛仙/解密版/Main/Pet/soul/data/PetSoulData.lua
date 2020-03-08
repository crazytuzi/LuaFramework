local Lplus = require("Lplus")
local PetUtility = require("Main.Pet.PetUtility")
local PetSoulData = Lplus.Class("PetSoulData")
local def = PetSoulData.define
local _instance
def.static("=>", PetSoulData).Instance = function()
  if _instance == nil then
    _instance = PetSoulData()
  end
  return _instance
end
def.field("table")._levelCfg = nil
def.field("table")._posCfg = nil
def.method().Init = function(self)
  self:_Reset()
end
def.method()._Reset = function(self)
  self._levelCfg = nil
  self._posCfg = nil
end
def.method()._LoadLevelCfg = function(self)
  warn("[PetSoulData:_LoadLevelCfg] start Load posLevelCfg!")
  self._levelCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CPetSoulCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local pos = DynamicRecord.GetIntValue(entry, "pos")
    local posLevelCfg = self._levelCfg[pos]
    if nil == posLevelCfg then
      posLevelCfg = {}
      posLevelCfg.pos = pos
      self._levelCfg[pos] = posLevelCfg
    end
    local levelCfgs = posLevelCfg.levelCfgs
    if nil == levelCfgs then
      levelCfgs = {}
      posLevelCfg.levelCfgs = levelCfgs
    end
    local levelCfg = {}
    levelCfg.level = DynamicRecord.GetIntValue(entry, "level")
    levelCfg.exp = DynamicRecord.GetIntValue(entry, "exp")
    levelCfg.addScore = DynamicRecord.GetIntValue(entry, "addScore")
    if nil == posLevelCfg.maxLevel or posLevelCfg.maxLevel < levelCfg.level then
      posLevelCfg.maxLevel = levelCfg.level
    end
    levelCfg.propList = {}
    local propStruct = entry:GetStructValue("propStruct")
    local propCount = propStruct:GetVectorSize("propList")
    for k = 1, propCount do
      local propCfg = {}
      local propRecord = propStruct:GetVectorValueByIdx("propList", k - 1)
      propCfg.propType = propRecord:GetIntValue("propType")
      propCfg.propValue = propRecord:GetIntValue("propValue")
      if propCfg.propValue and propCfg.propValue > 0 then
        table.insert(levelCfg.propList, propCfg)
      end
    end
    levelCfg.itemTypeList = {}
    local itemStruct = entry:GetStructValue("itemStruct")
    local itemCount = itemStruct:GetVectorSize("itemList")
    for k = 1, itemCount do
      local itemRecord = itemStruct:GetVectorValueByIdx("itemList", k - 1)
      local itemType = itemRecord:GetIntValue("itemId")
      if itemType > 0 then
        table.insert(levelCfg.itemTypeList, itemType)
      end
    end
    posLevelCfg.levelCfgs[levelCfg.level] = levelCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetLevelCfgs = function(self)
  if nil == self._levelCfg then
    self:_LoadLevelCfg()
  end
  return self._levelCfg
end
def.method("number", "number", "=>", "table").GetSoulCfg = function(self, pos, level)
  local result
  local posLevelCfg = self:_GetLevelCfgs()[pos]
  if posLevelCfg then
    result = posLevelCfg.levelCfgs[level]
  else
    warn("[ERROR][PetSoulData:GetSoulCfg] posLevelCfg nil for pos:", pos)
  end
  return result
end
def.method("number", "number", "=>", "table").GetSoulPropList = function(self, pos, level)
  local result
  local soulCfg = self:GetSoulCfg(pos, level)
  if soulCfg then
    result = soulCfg.propList
  else
    warn("[ERROR][PetSoulData:GetSoulPropList] soulCfg nil for pos & level:", pos, level)
  end
  return result
end
def.method("number", "=>", "number").GetSoulMaxLevel = function(self, pos)
  local result = PetUtility.Instance():GetPetConstants("PET_SOUL_MAX_LEVEL")
  local posLevelCfg = self:_GetLevelCfgs()[pos]
  if posLevelCfg then
    result = math.min(posLevelCfg.maxLevel, result)
  else
    warn("[ERROR][PetSoulData:GetSoulMaxLevel] posLevelCfg nil for pos:", pos)
  end
  return result
end
def.method("number", "number", "number", "=>", "table").GetSoulPropByIdx = function(self, pos, level, idx)
  local result
  local soulList = self:GetSoulPropList(pos, level)
  if soulList then
    result = soulList[idx]
  else
    warn("[ERROR][PetSoulData:GetSoulPropByIdx] soulList nil for pos & level:", pos, level)
  end
  return result
end
def.method("number", "number", "=>", "number").GetSoulLevelExp = function(self, pos, level)
  local result = 0
  local soulCfg = self:GetSoulCfg(pos, level)
  if soulCfg then
    result = soulCfg.exp
  else
    warn("[ERROR][PetSoulData:GetSoulLevelExp] soulCfg nil for pos & level:", pos, level)
  end
  return result
end
def.method("number", "number", "=>", "number").GetSoulScore = function(self, pos, level)
  local result = 0
  local soulCfg = self:GetSoulCfg(pos, level)
  if soulCfg then
    result = soulCfg.addScore
  else
    warn("[ERROR][PetSoulData:GetSoulScore] soulCfg nil for pos & level:", pos, level)
  end
  return result
end
def.method()._LoadPosCfg = function(self)
  warn("[PetSoulData:_LoadPosCfg] start Load posCfg!")
  self._posCfg = {}
  local entries = DynamicData.GetTable(CFG_PATH.DATA_CPetSoulLookCfg)
  local count = DynamicDataTable.GetRecordsCount(entries)
  DynamicDataTable.FastGetRecordBegin(entries)
  for i = 1, count do
    local entry = DynamicDataTable.GetRecordByIdx(entries, i - 1)
    local posCfg = {}
    posCfg.pos = DynamicRecord.GetIntValue(entry, "pos")
    posCfg.name = DynamicRecord.GetStringValue(entry, "name")
    posCfg.img = DynamicRecord.GetIntValue(entry, "img")
    posCfg.tip = DynamicRecord.GetStringValue(entry, "tip")
    self._posCfg[posCfg.pos] = posCfg
  end
  DynamicDataTable.FastGetRecordEnd(entries)
end
def.method("=>", "table")._GetPosCfgs = function(self)
  if nil == self._posCfg then
    self:_LoadPosCfg()
  end
  return self._posCfg
end
def.method("number", "=>", "table").GetPosCfg = function(self, pos)
  return self:_GetPosCfgs()[pos]
end
def.method("table", "table").OnLeaveWorld = function(self, p1, p2)
  self:_Reset()
end
PetSoulData.Commit()
return PetSoulData
