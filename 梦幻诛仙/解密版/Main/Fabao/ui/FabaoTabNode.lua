local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TabNode = require("GUI.TabNode")
local FabaoTabNode = Lplus.Extend(TabNode, "FabaoTabNode")
local def = FabaoTabNode.define
def.field("table").m_Params = nil
def.virtual("table").ShowWithParams = function(self, params)
  self.m_Params = params
  self:Show()
end
def.virtual("=>", "boolean").HasSubNode = function(self)
  return false
end
FabaoTabNode.Commit()
return FabaoTabNode
