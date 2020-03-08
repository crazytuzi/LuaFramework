local MODULE_NAME = (...)
local Lplus = require("Lplus")
local BaseMemoUnit = import(".BaseMemoUnit")
local BreedMemoUnit = Lplus.Extend(BaseMemoUnit, MODULE_NAME)
local GrowthSubType = require("netio.protocol.mzm.gsp.children.GrowthSubType")
local BabyPropertyEnum = require("consts.mzm.gsp.children.confbean.BabyPropertyEnum")
local def = BreedMemoUnit.define
local PropertyColor = {positive = "009a01", negative = "ff0f0f"}
local NegativeProperties = {
  [BabyPropertyEnum.TIRED] = true
}
def.field("number").m_operator = 0
def.override("number", "userdata", "table").Init = function(self, type, occurtime, params)
  BaseMemoUnit.Init(self, type, occurtime, params)
  self.m_operator = self.m_intParams[GrowthSubType.BABY_BREED_OPERAT] or self.m_operator
end
def.override("=>", "string").GetFormattedText = function(self)
  local strTable = {}
  table.insert(strTable, self:GetOperatorName())
  local properties = self:GetEffectedProperties()
  for i, prop in ipairs(properties) do
    table.insert(strTable, BaseMemoUnit.SYMBOL_DELIMITER)
    table.insert(strTable, "[")
    local color = self:GetPropChangeColor(prop.k, prop.v)
    table.insert(strTable, color)
    table.insert(strTable, "]")
    table.insert(strTable, self:GetPropertyName(prop.k))
    if prop.v > 0 then
      table.insert(strTable, BaseMemoUnit.SYMBOL_INCREMENT)
    else
      table.insert(strTable, BaseMemoUnit.SYMBOL_DECREMENT)
    end
    table.insert(strTable, math.abs(prop.v))
    table.insert(strTable, "[-]")
  end
  return table.concat(strTable)
end
def.method("=>", "string").GetOperatorName = function(self)
  return textRes.Children.BabyOperateName[self.m_operator] or "nil"
end
def.method("number", "number", "=>", "string").GetPropChangeColor = function(self, prop, change)
  local positive = change > 0
  if self:IsNegativeProp(prop) then
    positive = not positive
  end
  return positive and PropertyColor.positive or PropertyColor.negative
end
def.method("number", "=>", "boolean").IsNegativeProp = function(self, prop)
  return NegativeProperties[prop] == true
end
def.method("number", "=>", "string").GetPropertyName = function(self, prop)
  return textRes.Children.BabyPropertyName[prop] or "nil"
end
def.method("=>", "table").GetEffectedProperties = function(self)
  local allProperties = {}
  for k, v in pairs(BabyPropertyEnum) do
    allProperties[#allProperties + 1] = v
  end
  table.sort(allProperties)
  local effectedProperties = {}
  for i, k in ipairs(allProperties) do
    local val = self.m_intParams[k]
    if val and val ~= 0 then
      local property = {k = k, v = val}
      effectedProperties[#effectedProperties + 1] = property
    end
  end
  return effectedProperties
end
return BreedMemoUnit.Commit()
