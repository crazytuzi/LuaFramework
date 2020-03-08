local Lplus = require("Lplus")
local ChildAssignPropScheme = Lplus.Class("ChildAssignPropScheme")
local def = ChildAssignPropScheme.define
local ChildBaseProp = require("Main.Children.data.ChildBaseProp")
def.field("number").schemeId = -1
def.field(ChildBaseProp).autoAssigned = nil
def.field(ChildBaseProp).autoAssigning = nil
def.field("number").autoAssignPointLimit = 10
def.field("number").autoAssignedPoint = 0
def.method("table").RawSet = function(self, data)
  self.autoAssigned = ChildBaseProp()
  self.autoAssigned:RawSet(data)
  self:ResetAutoAssigning()
end
def.method().SaveManualAssign = function(self)
end
def.method().Clear = function(self)
  self:ResetAutoAssigning()
end
def.method().ClearAutoAssigning = function(self)
  self.autoAssigning = ChildBaseProp()
  self.autoAssignedPoint = 0
end
def.method("=>", ChildBaseProp).GetAutoAssigning = function(self)
  if self.autoAssigning == nil then
    self.autoAssigning = ChildBaseProp()
    self.autoAssigning:Add(self.autoAssigned)
    self.autoAssignedPoint = self.autoAssigning.str + self.autoAssigning.sta + self.autoAssigning.con + self.autoAssigning.spi + self.autoAssigning.dex
  end
  return self.autoAssigning
end
def.method().SaveAutoAssigning = function(self)
  self.autoAssigned:Sub(self.autoAssigned)
  self.autoAssigned:Add(self.autoAssigning)
  self.autoAssignedPoint = self.autoAssignPointLimit
end
def.method().ResetAutoAssigning = function(self)
  if self.autoAssigning == nil then
    self.autoAssigning = ChildBaseProp()
    self.autoAssigning:Add(self.autoAssigned)
  else
    self.autoAssigning:Sub(self.autoAssigning)
    self.autoAssigning:Add(self.autoAssigned)
  end
  self.autoAssignedPoint = self.autoAssigning.str + self.autoAssigning.sta + self.autoAssigning.con + self.autoAssigning.spi + self.autoAssigning.dex
end
ChildAssignPropScheme.Commit()
return ChildAssignPropScheme
