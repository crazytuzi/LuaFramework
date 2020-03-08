local Lplus = require("Lplus")
local WingPropsStruct = Lplus.Class("WingPropsStruct")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local def = WingPropsStruct.define
def.field("number").PHYATK = 0
def.field("number").PHYDEF = 0
def.field("number").MAGATK = 0
def.field("number").MAGDEF = 0
def.field("number").MAX_HP = 0
def.field("number").SPEED = 0
def.field("number").PHY_CRIT_LEVEL = 0
def.field("number").PHY_CRT_DEF_LEVEL = 0
def.field("number").MAG_CRT_LEVEL = 0
def.field("number").MAG_CRT_DEF_LEVEL = 0
def.field("number").SEAL_HIT = 0
def.field("number").SEAL_RESIST = 0
def.method("number", "number").SetValueByType = function(self, type, value)
  if type == PropertyType.PHYATK then
    self.PHYATK = value
  elseif type == PropertyType.PHYDEF then
    self.PHYDEF = value
  elseif type == PropertyType.MAGATK then
    self.MAGATK = value
  elseif type == PropertyType.MAGDEF then
    self.MAGDEF = value
  elseif type == PropertyType.MAX_HP then
    self.MAX_HP = value
  elseif type == PropertyType.SPEED then
    self.SPEED = value
  elseif type == PropertyType.PHY_CRIT_LEVEL then
    self.PHY_CRIT_LEVEL = value
  elseif type == PropertyType.PHY_CRT_DEF_LEVEL then
    self.PHY_CRT_DEF_LEVEL = value
  elseif type == PropertyType.MAG_CRT_LEVEL then
    self.MAG_CRT_LEVEL = value
  elseif type == PropertyType.MAG_CRT_DEF_LEVEL then
    self.MAG_CRT_DEF_LEVEL = value
  elseif type == PropertyType.SEAL_HIT then
    self.SEAL_HIT = value
  elseif type == PropertyType.SEAL_RESIST then
    self.SEAL_RESIST = value
  end
end
def.method("table").Plus = function(self, other)
  self.PHYATK = self.PHYATK + other.PHYATK
  self.PHYDEF = self.PHYDEF + other.PHYDEF
  self.MAGATK = self.MAGATK + other.MAGATK
  self.MAGDEF = self.MAGDEF + other.MAGDEF
  self.MAX_HP = self.MAX_HP + other.MAX_HP
  self.SPEED = self.SPEED + other.SPEED
  self.PHY_CRIT_LEVEL = self.PHY_CRIT_LEVEL + other.PHY_CRIT_LEVEL
  self.PHY_CRT_DEF_LEVEL = self.PHY_CRT_DEF_LEVEL + other.PHY_CRT_DEF_LEVEL
  self.MAG_CRT_LEVEL = self.MAG_CRT_LEVEL + other.MAG_CRT_LEVEL
  self.MAG_CRT_DEF_LEVEL = self.MAG_CRT_DEF_LEVEL + other.MAG_CRT_DEF_LEVEL
  self.SEAL_HIT = self.SEAL_HIT + other.SEAL_HIT
  self.SEAL_RESIST = self.SEAL_RESIST + other.SEAL_RESIST
end
return WingPropsStruct.Commit()
