local Lplus = require("Lplus")
local PetSecondProp = Lplus.Class("PetSecondProp")
local def = PetSecondProp.define
def.field("number").maxHp = 0
def.field("number").maxMp = 0
def.field("number").phyAtk = 0
def.field("number").phyDef = 0
def.field("number").magAtk = 0
def.field("number").magDef = 0
def.field("number").speed = 0
def.method("table").RawSet = function(self, data)
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  self.maxHp = data[PropertyType.MAX_HP] or 0
  self.maxMp = data[PropertyType.MAX_MP] or 0
  self.phyAtk = data[PropertyType.PHYATK] or 0
  self.phyDef = data[PropertyType.PHYDEF] or 0
  self.magAtk = data[PropertyType.MAGATK] or 0
  self.magDef = data[PropertyType.MAGDEF] or 0
  self.speed = data[PropertyType.SPEED] or 0
end
def.method(PetSecondProp).Add = function(self, oprand)
  if oprand == nil then
    return
  end
  self.phyAtk = self.phyAtk + oprand.phyAtk
  self.phyDef = self.phyDef + oprand.phyDef
  self.magAtk = self.magAtk + oprand.magAtk
  self.magDef = self.magDef + oprand.magDef
  self.speed = self.speed + oprand.speed
end
def.method(PetSecondProp).Sub = function(self, oprand)
  if oprand == nil then
    return
  end
  self.phyAtk = self.phyAtk - oprand.phyAtk
  self.phyDef = self.phyDef - oprand.phyDef
  self.magAtk = self.magAtk - oprand.magAtk
  self.magDef = self.magDef - oprand.magDef
  self.speed = self.speed - oprand.speed
end
PetSecondProp.Commit()
return PetSecondProp
