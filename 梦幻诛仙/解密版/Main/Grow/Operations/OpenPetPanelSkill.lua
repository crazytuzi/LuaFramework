local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local OpenPetPanel = import(".OpenPetPanel")
local OpenPetPanelSkill = Lplus.Extend(OpenPetPanel, CUR_CLASS_NAME)
local PetPanel = require("Main.Pet.ui.PetPanel")
local def = OpenPetPanelSkill.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  self.nodeId = PetPanel.NodeId.SkillNode
  return OpenPetPanel.Operate(self, params)
end
return OpenPetPanelSkill.Commit()
