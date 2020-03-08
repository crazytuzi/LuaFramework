local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPetAndDecoratePanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local PetPanel = require("Main.Pet.ui.PetPanel")
local def = OpenPetAndDecoratePanel.define
def.field("number").nodeId = PetPanel.NodeId.BasicNode
def.override("table", "=>", "boolean").Operate = function(self, params)
  local fightingPet = require("Main.Pet.Interface").GetFightingPet()
  if fightingPet then
    PetPanel.Instance().selectedPetId = fightingPet.id
    PetPanel.Instance():ShowPanelEx(self.nodeId)
    if not fightingPet.isDecorated then
      local PetDecorationPanel = require("Main.Pet.ui.PetDecorationPanel")
      PetDecorationPanel.Instance():SetActivePet(fightingPet.id)
      PetDecorationPanel.Instance():ShowPanel()
    end
  else
    PetPanel.Instance():ShowPanelEx(self.nodeId)
  end
  return false
end
return OpenPetAndDecoratePanel.Commit()
