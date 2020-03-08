local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenPetPanel = import(".OpenPetPanel")
local OpenPetPanelFanSheng = Lplus.Extend(OpenPetPanel, CUR_CLASS_NAME)
local PetPanel = require("Main.Pet.ui.PetPanel")
local def = OpenPetPanelFanSheng.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = PetPanel.NodeId.FanShengNode
  return OpenPetPanel.Operate(self, params)
end
return OpenPetPanelFanSheng.Commit()
