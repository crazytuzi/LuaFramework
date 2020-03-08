local Lplus = require("Lplus")
local HeroAssignPointScheme = Lplus.Class("HeroAssignPointScheme")
local def = HeroAssignPointScheme.define
local HeroBaseProp = require("Main.Hero.data.HeroBaseProp")
local HeroSecondProp = require("Main.Hero.data.HeroSecondProp")
def.field("number").schemeId = -1
def.field(HeroBaseProp).baseProp = nil
def.field(HeroSecondProp).secondProp = nil
def.field("number").potentialPoint = 0
def.field("boolean").isEnableAutoAssign = false
def.field("boolean").isCanRefreshProp = false
def.field(HeroBaseProp).totalBaseProp = nil
def.field(HeroBaseProp).manualAssigning = nil
def.field(HeroSecondProp).secondPropPreview = nil
def.field("number").manualAssignedPoint = 0
def.field(HeroBaseProp).autoAssigned = nil
def.field(HeroBaseProp).autoAssigning = nil
def.field("number").autoAssignPointLimit = 10
def.field("number").autoAssignedPoint = 0
def.method("number", "table").RawSet = function(self, id, data)
  self.schemeId = id
  self.potentialPoint = data.potential_point
  self.isEnableAutoAssign = data.isAutoAssign == 1
  self.isCanRefreshProp = data.isCanRefreshProp == 1
  self.baseProp = HeroBaseProp()
  self.baseProp:RawSet(data.propMap)
  self.totalBaseProp = HeroBaseProp()
  self.totalBaseProp:RawSet(data.basePropMap)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
  self.secondProp = HeroPropMgr.Instance():GetHeroProp().secondProp
  self.autoAssigned = HeroBaseProp()
  self.autoAssigned:RawSet(data.autoAssignMap)
end
def.method().SaveManualAssign = function(self)
  self.baseProp:Add(self.manualAssigning)
  self.potentialPoint = self.potentialPoint - self.manualAssignedPoint
end
def.method().Clear = function(self)
  self.manualAssigning = nil
  self.secondPropPreview = nil
  self.manualAssignedPoint = 0
  self:ResetAutoAssigning()
end
def.method().ClearAutoAssigning = function(self)
  self.autoAssigning = HeroBaseProp()
  self.autoAssignedPoint = 0
end
def.method("=>", HeroBaseProp).GetManualAssigning = function(self)
  if self.manualAssigning == nil then
    self.manualAssigning = HeroBaseProp()
  end
  return self.manualAssigning
end
def.method("=>", HeroBaseProp).GetAutoAssigning = function(self)
  if self.autoAssigning == nil then
    self.autoAssigning = HeroBaseProp()
    self.autoAssigning:Add(self.autoAssigned)
    self.autoAssignedPoint = self.autoAssigning.str + self.autoAssigning.sta + self.autoAssigning.con + self.autoAssigning.spi + self.autoAssigning.dex
  end
  return self.autoAssigning
end
def.method("=>", HeroSecondProp).GetPreviewedSecondProp = function(self)
  if self.secondPropPreview == nil then
    self.secondPropPreview = HeroSecondProp()
  end
  return self.secondPropPreview
end
def.method().SaveAutoAssigning = function(self)
  self.autoAssigned:Sub(self.autoAssigned)
  self.autoAssigned:Add(self.autoAssigning)
  self.autoAssignedPoint = self.autoAssignPointLimit
end
def.method().ResetAutoAssigning = function(self)
  if self.autoAssigning == nil then
    self.autoAssigning = HeroBaseProp()
    self.autoAssigning:Add(self.autoAssigned)
  else
    self.autoAssigning:Sub(self.autoAssigning)
    self.autoAssigning:Add(self.autoAssigned)
  end
  self.autoAssignedPoint = self.autoAssigning.str + self.autoAssigning.sta + self.autoAssigning.con + self.autoAssigning.spi + self.autoAssigning.dex
end
HeroAssignPointScheme.Commit()
return HeroAssignPointScheme
