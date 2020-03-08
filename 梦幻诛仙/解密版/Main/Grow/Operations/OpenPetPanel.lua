local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPetPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local PetPanel = require("Main.Pet.ui.PetPanel")
local def = OpenPetPanel.define
def.field("number").nodeId = PetPanel.NodeId.BasicNode
def.override("table", "=>", "boolean").Operate = function(self, params)
  PetPanel.Instance():ShowPanelEx(self.nodeId)
  return false
end
return OpenPetPanel.Commit()
