local Lplus = require("Lplus")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local HeroSecondProp = Lplus.Class("HeroSecondProp")
local def = HeroSecondProp.define
def.const("table").attrNameList = {
  "maxHp",
  "maxMp",
  "phyAtk",
  "magAtk",
  "phyDef",
  "magDef",
  "speed"
}
def.field("number").maxHp = 0
def.field("number").maxMp = 0
def.field("number").phyAtk = 0
def.field("number").phyDef = 0
def.field("number").magAtk = 0
def.field("number").magDef = 0
def.field("number").speed = 0
def.method("table").RawSet = function(self, data)
  if data == nil then
    return
  end
  self.maxHp = data[PropertyType.MAX_HP] or 0
  self.maxMp = data[PropertyType.MAX_MP] or 0
  self.phyAtk = data[PropertyType.PHYATK] or 0
  self.phyDef = data[PropertyType.PHYDEF] or 0
  self.magAtk = data[PropertyType.MAGATK] or 0
  self.magDef = data[PropertyType.MAGDEF] or 0
  self.speed = data[PropertyType.SPEED] or 0
end
def.method(HeroSecondProp).Add = function(self, oprand)
  if oprand == nil then
    return
  end
  for i, attrName in ipairs(HeroSecondProp.attrNameList) do
    self[attrName] = self[attrName] + oprand[attrName]
  end
end
def.method(HeroSecondProp).Sub = function(self, oprand)
  if oprand == nil then
    return
  end
  for i, attrName in ipairs(HeroSecondProp.attrNameList) do
    self[attrName] = self[attrName] - oprand[attrName]
  end
end
def.method("=>", "boolean").IsZero = function(self)
  for i, attrName in ipairs(HeroSecondProp.attrNameList) do
    if self[attrName] ~= 0 then
      return false
    end
  end
  return true
end
def.method("string", "=>", "string").ToText = function(self, attrName)
  return textRes.Hero.prop[attrName]
end
def.method(HeroSecondProp).Copy = function(self, prop)
  if prop == nil then
    return
  end
  for i, attrName in ipairs(HeroSecondProp.attrNameList) do
    self[attrName] = prop[attrName]
  end
end
HeroSecondProp.Commit()
return HeroSecondProp
