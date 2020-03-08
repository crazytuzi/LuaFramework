local Lplus = require("Lplus")
local HeroBaseProp = Lplus.Class("HeroBaseProp")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local def = HeroBaseProp.define
def.const("table").attrNameList = {
  "str",
  "dex",
  "con",
  "sta",
  "spi"
}
def.field("number").str = 0
def.field("number").dex = 0
def.field("number").con = 0
def.field("number").sta = 0
def.field("number").spi = 0
def.method("table").RawSet = function(self, data)
  if data == nil then
    return
  end
  self.str = data[PropertyType.STR] or 0
  self.dex = data[PropertyType.DEX] or 0
  self.con = data[PropertyType.CON] or 0
  self.sta = data[PropertyType.STA] or 0
  self.spi = data[PropertyType.SPR] or 0
end
def.method(HeroBaseProp).Add = function(self, oprand)
  if oprand == nil then
    return
  end
  for i, attrName in ipairs(HeroBaseProp.attrNameList) do
    self[attrName] = self[attrName] + oprand[attrName]
  end
end
def.method(HeroBaseProp).Sub = function(self, oprand)
  if oprand == nil then
    return
  end
  for i, attrName in ipairs(HeroBaseProp.attrNameList) do
    self[attrName] = self[attrName] - oprand[attrName]
  end
end
def.method("string", "=>", "string").ToText = function(self, attrName)
  return textRes.Hero.prop[attrName]
end
def.method(HeroBaseProp).Copy = function(self, prop)
  if prop == nil then
    return
  end
  for i, attrName in ipairs(HeroBaseProp.attrNameList) do
    self[attrName] = prop[attrName]
  end
end
HeroBaseProp.Commit()
return HeroBaseProp
