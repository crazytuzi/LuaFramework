local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local TabNode = require("GUI.TabNode")
local GodWeaponTabNode = Lplus.Extend(TabNode, "GodWeaponTabNode")
local def = GodWeaponTabNode.define
def.field("table")._params = nil
def.virtual("table").ShowWithParams = function(self, params)
  self._params = params
  self:Show()
end
def.virtual("=>", "boolean").HasSubNode = function(self)
  return false
end
def.virtual("number", "userdata", "table").OnEquipSelected = function(self, idx, clickObj, equipInfo)
end
return GodWeaponTabNode.Commit()
