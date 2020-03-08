local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local HeroPropPanelNodeBase = Lplus.Extend(TabNode, "HeroPropPanelNodeBase")
local def = HeroPropPanelNodeBase.define
def.field("number").nodeId = 0
def.virtual("string", "boolean").onToggle = function(self, id, isActive)
end
def.override("string").onDragStart = function(self, id)
end
def.override("string").onDragEnd = function(self, id)
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
end
def.virtual().InitUI = function(self)
end
def.virtual().UpdateUI = function(self)
end
def.virtual("table", "table").OnSyncHeroProp = function(self, params, context)
end
def.virtual("=>", "boolean").HasNotify = function(self)
  return false
end
def.virtual("=>", "boolean").IsUnlock = function(self)
  return true
end
return HeroPropPanelNodeBase.Commit()
