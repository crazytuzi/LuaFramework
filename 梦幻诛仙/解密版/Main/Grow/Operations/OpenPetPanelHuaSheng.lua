local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenPetPanel = import(".OpenPetPanel")
local OpenPetPanelHuaSheng = Lplus.Extend(OpenPetPanel, CUR_CLASS_NAME)
local PetPanel = require("Main.Pet.ui.PetPanel")
local def = OpenPetPanelHuaSheng.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = PetPanel.NodeId.HuaShengNode
  return OpenPetPanel.Operate(self, params)
end
return OpenPetPanelHuaSheng.Commit()
