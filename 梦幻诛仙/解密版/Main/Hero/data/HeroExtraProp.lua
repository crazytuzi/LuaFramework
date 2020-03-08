local Lplus = require("Lplus")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local HeroExtraProp = Lplus.Class("HeroExtraProp")
local def = HeroExtraProp.define
def.const("table").attrNameList = {
  "antiSeal",
  "phyCritical",
  "magCritical"
}
def.field("number").antiSeal = 0
def.field("number").phyCritical = 0
def.field("number").magCritical = 0
def.method("table").RawSet = function(self, data)
  if data == nil then
    return
  end
  self.antiSeal = data[PropertyType.SEAL_RESIST] or 0
  self.phyCritical = data[PropertyType.PHY_CRT_RATE] or 0
  self.magCritical = data[PropertyType.MAG_CRT_RATE] or 0
end
def.method(HeroExtraProp).Add = function(self, oprand)
  if oprand == nil then
    return
  end
  for i, attrName in ipairs(HeroExtraProp.attrNameList) do
    self[attrName] = self[attrName] + oprand[attrName]
  end
end
def.method(HeroExtraProp).Sub = function(self, oprand)
  if oprand == nil then
    return
  end
  for i, attrName in ipairs(HeroExtraProp.attrNameList) do
    self[attrName] = self[attrName] - oprand[attrName]
  end
end
def.method("=>", "boolean").IsZero = function(self)
  for i, attrName in ipairs(HeroExtraProp.attrNameList) do
    if self[attrName] ~= 0 then
      return false
    end
  end
  return true
end
def.method("string", "=>", "string").ToText = function(self, attrName)
  return textRes.Hero.prop[attrName]
end
def.method(HeroExtraProp).Copy = function(self, prop)
  if prop == nil then
    return
  end
  for i, attrName in ipairs(HeroExtraProp.attrNameList) do
    self[attrName] = prop[attrName]
  end
end
HeroExtraProp.Commit()
return HeroExtraProp
