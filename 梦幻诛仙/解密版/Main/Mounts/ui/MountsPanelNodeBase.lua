local Lplus = require("Lplus")
local TabNode = require("GUI.TabNode")
local ECPanelBase = require("GUI.ECPanelBase")
local MountsPanelNodeBase = Lplus.Extend(TabNode, "MountsPanelNodeBase")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local def = MountsPanelNodeBase.define
def.field("userdata").curMountsId = nil
def.virtual("userdata").ChooseMounts = function(self, mountsId)
  self.curMountsId = mountsId
end
def.virtual().NoMounts = function(self)
  self.curMountsId = nil
end
MountsPanelNodeBase.Commit()
return MountsPanelNodeBase
