local Lplus = require("Lplus")
local PetAssignPropScheme = Lplus.Class("PetAssignPropScheme")
local def = PetAssignPropScheme.define
local PetBaseProp = require("Main.Pet.data.PetBaseProp")
local PetSecondProp = require("Main.Pet.data.PetSecondProp")
def.field("number").schemeId = -1
def.field("number").potentialPoint = 0
def.field("boolean").isEnableAutoAssign = false
def.field(PetBaseProp).manualAssigning = nil
def.field(PetSecondProp).secondPropPreview = nil
def.field("number").manualAssignedPoint = 0
def.field(PetBaseProp).autoAssigned = nil
def.field(PetBaseProp).autoAssigning = nil
def.field("number").autoAssignPointLimit = 10
def.field("number").autoAssignedPoint = 0
def.method("table").RawSet = function(self, data)
  self.potentialPoint = data.potentialPoint or 0
  self.isEnableAutoAssign = data.isAutoAddFlagOpen == 1
  self.autoAssigned = PetBaseProp()
  self.autoAssigned:RawSet(data.autoAddPropPref)
  self:ResetAutoAssigning()
end
def.method().SaveManualAssign = function(self)
end
def.method().Clear = function(self)
  self.manualAssigning = nil
  self.secondPropPreview = nil
  self.manualAssignedPoint = 0
  self:ResetAutoAssigning()
end
def.method().ClearAutoAssigning = function(self)
  self.autoAssigning = PetBaseProp()
  self.autoAssignedPoint = 0
end
def.method("=>", PetBaseProp).GetManualAssigning = function(self)
  if self.manualAssigning == nil then
    self.manualAssigning = PetBaseProp()
  end
  return self.manualAssigning
end
def.method("=>", PetBaseProp).GetAutoAssigning = function(self)
  if self.autoAssigning == nil then
    self.autoAssigning = PetBaseProp()
    self.autoAssigning:Add(self.autoAssigned)
    self.autoAssignedPoint = self.autoAssigning.str + self.autoAssigning.sta + self.autoAssigning.con + self.autoAssigning.spi + self.autoAssigning.dex
  end
  return self.autoAssigning
end
def.method("=>", PetSecondProp).GetPreviewedSecondProp = function(self)
  if self.secondPropPreview == nil then
    self.secondPropPreview = PetSecondProp()
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
    self.autoAssigning = PetBaseProp()
    self.autoAssigning:Add(self.autoAssigned)
  else
    self.autoAssigning:Sub(self.autoAssigning)
    self.autoAssigning:Add(self.autoAssigned)
  end
  self.autoAssignedPoint = self.autoAssigning.str + self.autoAssigning.sta + self.autoAssigning.con + self.autoAssigning.spi + self.autoAssigning.dex
end
PetAssignPropScheme.Commit()
return PetAssignPropScheme
