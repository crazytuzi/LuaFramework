local Lplus = require("Lplus")
local HeroProp = Lplus.Class("HeroProp")
local def = HeroProp.define
local ECGame = Lplus.ForwardDeclare("ECGame")
local HeroBaseProp = require("Main.Hero.data.HeroBaseProp")
local HeroSecondProp = require("Main.Hero.data.HeroSecondProp")
local HeroExtraProp = require("Main.Hero.data.HeroExtraProp")
def.field("userdata").id = nil
def.field("string").name = ""
def.field("number").gender = -1
def.field("number").occupation = -1
def.field("number").level = 0
def.field("number").energy = 0
def.field("number").hp = 0
def.field("number").mp = 0
def.field("number").anger = 0
def.field("number").exp = 0
def.field("number").potential = 0
def.field("number").fightValue = 0
def.field("userdata").createTime = nil
def.field(HeroBaseProp).baseProp = nil
def.field(HeroSecondProp).secondProp = nil
def.field(HeroExtraProp).extraProp = nil
def.field("table").propMap = nil
def.field("boolean").isInited = false
def.field("number")._maxEnergy = 0
def.field("number").nextLevelExp = 0
def.field("table").model = nil
def.field("table").appellation = nil
def.field("string").gangName = ""
def.method("table").RawSet = function(self, data)
  local prop = data
  self.id = prop.roleid
  self.name = prop.name
  self.gender = prop.gender
  self.occupation = prop.occupation
  self.level = prop.level
  self.energy = prop.vigor
  self.hp = prop.hp
  self.mp = prop.mp
  self.anger = prop.anger or 0
  self.exp = Int64.ToNumber(prop.exp)
  self.potential = 0
  self.fightValue = prop.fightValue
  self.propMap = prop.propMap
  self.createTime = prop.createTime or Int64.new(0)
  if self.baseProp == nil then
    self.baseProp = HeroBaseProp()
  end
  local activityProp = prop.propSysMap[prop.activityPropSys]
  self.baseProp:RawSet(activityProp.propMap)
  if self.secondProp == nil then
    self.secondProp = HeroSecondProp()
  end
  self.secondProp:RawSet(prop.propMap)
  if self.extraProp == nil then
    self.extraProp = HeroExtraProp()
  end
  self.extraProp:RawSet(prop.propMap)
  local hapMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  hapMgr:ClearAssignPointScheme()
  for k, v in pairs(prop.propSysMap) do
    hapMgr:AddAssignPointScheme(k, v)
  end
  hapMgr:SetEnabledSchemeIndex(prop.activityPropSys)
  self.isInited = true
end
def.method("=>", "number").GetMaxAnger = function(self)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
  return HeroPropMgr.Instance():GetRoleMaxAnger()
end
def.method("=>", "number").GetMaxEnergy = function(self)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
  return HeroPropMgr.Instance():GetRoleMaxEnergy(self.level)
end
def.method(HeroProp).Copy = function(self, prop)
  self.id = prop.id
  self.name = prop.name
  self.gender = prop.gender
  self.occupation = prop.occupation
  self.level = prop.level
  self.energy = prop.energy
  self.hp = prop.hp
  self.mp = prop.mp
  self.anger = prop.anger
  self.exp = prop.exp
  self.potential = prop.potential
  self.fightValue = prop.fightValue
  self.propMap = clone(prop.propMap)
  self.isInited = prop.isInited
  if self.baseProp == nil then
    self.baseProp = HeroBaseProp()
  end
  self.baseProp:Copy(prop.baseProp)
  if self.secondProp == nil then
    self.secondProp = HeroSecondProp()
  end
  self.secondProp:Copy(prop.secondProp)
  if self.extraProp == nil then
    self.extraProp = HeroExtraProp()
  end
  self.extraProp:Copy(prop.extraProp)
end
HeroProp.Commit()
return HeroProp
