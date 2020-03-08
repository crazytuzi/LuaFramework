local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local PetSoulData = require("Main.Pet.soul.data.PetSoulData")
local PetSoulPos = require("consts.mzm.gsp.petsoul.confbean.PetSoulPos")
local PetSoulProp = Lplus.Class(CUR_CLASS_NAME)
local def = PetSoulProp.define
def.const("table").POS_LIST = {
  PetSoulPos.POS_JING,
  PetSoulPos.POS_QI,
  PetSoulPos.POS_SHEN
}
def.field("table")._petData = nil
def.field("table")._soulTable = nil
def.final("table", "table", "=>", PetSoulProp).New = function(petData, soulTable)
  local prop = PetSoulProp()
  prop._petData = petData
  prop._soulTable = soulTable
  return prop
end
def.method().Release = function(self)
  self._petData = nil
  self._soulTable = nil
end
def.method("number", "=>", "table").GetSoulInfoByPos = function(self, pos)
  local result
  if self._soulTable then
    result = self._soulTable[pos]
  end
  return result
end
def.method("=>", "number").GetPetLevel = function(self)
  local result = 0
  if self._petData then
    result = self._petData.level
  else
    warn("[ERROR][PetSoulProp:GetPetLevel] self._petData nil.")
  end
  return result
end
def.method("number", "=>", "number").GetSoulLevel = function(self, pos)
  local result = 0
  if self._soulTable then
    local soulInfo = self:GetSoulInfoByPos(pos)
    result = soulInfo and soulInfo.level or 0
  else
    warn("[ERROR][PetSoulProp:GetSoulLevel] self._soulTable nil.")
  end
  return result
end
def.method("number", "=>", "table").GetSoulLevelupItemTypes = function(self, pos)
  local result
  local level = self:GetSoulLevel(pos)
  local soulCfg = PetSoulData.Instance():GetSoulCfg(pos, level)
  if soulCfg then
    result = soulCfg.itemTypeList
  else
    warn("[ERROR][PetSoulProp:GetSoulLevelupItemTypes] soulCfg nil for pos & level:", pos, level)
  end
  return result
end
def.method("number", "=>", "table").GetSoulPropList = function(self, pos)
  local level = self:GetSoulLevel(pos)
  local result = PetSoulData.Instance():GetSoulPropList(pos, level)
  return result
end
def.method("number", "=>", "number").GetSoulPropIdx = function(self, pos)
  local result = 0
  if self._soulTable then
    local soulInfo = self:GetSoulInfoByPos(pos)
    result = soulInfo and soulInfo.propIndex or 0
  else
    warn("[ERROR][PetSoulProp:GetSoulPropIdx] self._soulTable nil.")
  end
  return result
end
def.method("number", "=>", "table").GetSoulProp = function(self, pos)
  local result
  local propIdx = self:GetSoulPropIdx(pos)
  local propList = self:GetSoulPropList(pos)
  if propList then
    result = propList and propList[propIdx]
    if result then
      result.pos = pos
    end
  else
    warn("[ERROR][PetSoulProp:GetSoulProp] propList nil for pos:", pos)
  end
  return result
end
def.method("=>", "table").GetAllSoulProp = function(self)
  local result = {}
  for _, pos in ipairs(PetSoulProp.POS_LIST) do
    local soulProp = self:GetSoulProp(pos)
    if soulProp then
      table.insert(result, soulProp)
    end
  end
  return result
end
def.method("=>", "number").GetScore = function(self)
  local result = 0
  for _, pos in pairs(PetSoulProp.POS_LIST) do
    local soulInfo = self:GetSoulInfoByPos(pos)
    if soulInfo then
      result = result + PetSoulData.Instance():GetSoulScore(pos, soulInfo.level)
    end
  end
  return result
end
return PetSoulProp.Commit()
