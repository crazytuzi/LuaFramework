local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local RelationShipChainPanelNodeBase = Lplus.Extend(TabNode, "RelationShipChainPanelNodeBase")
local def = RelationShipChainPanelNodeBase.define
def.field("table").m_Item = nil
def.field("table").m_UIGO = nil
def.virtual().InitUI = function(self)
end
def.virtual().Clear = function(self)
  self.m_Item = nil
  self.m_UIGO = nil
end
def.virtual("=>", "boolean").IsUnlock = function(self)
  return false
end
def.virtual("table").UpdateItem = function(self, item)
  self.m_Item = item
end
def.virtual().UpdateMoney = function(self)
end
RelationShipChainPanelNodeBase.Commit()
return RelationShipChainPanelNodeBase
