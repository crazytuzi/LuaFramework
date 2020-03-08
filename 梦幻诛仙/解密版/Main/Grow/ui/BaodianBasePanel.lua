local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local BaodianBasePanel = Lplus.Extend(ECPanelBase, "BaodianBasePanel")
local def = BaodianBasePanel.define
def.virtual("userdata").ShowPanel = function(self, parentPanel)
end
def.virtual("userdata", "number").ShowPanelWithTargetNode = function(self, parentPanel, subNode)
  if not self:NeedSubNode() then
    return
  end
end
def.virtual("=>", "boolean").NeedSubNode = function(self)
  return false
end
def.virtual("number", "=>", "boolean").CheckNodeExist = function(self, targetSubNode)
  return false
end
def.virtual().ReleaseUI = function(self)
end
BaodianBasePanel.Commit()
return BaodianBasePanel
