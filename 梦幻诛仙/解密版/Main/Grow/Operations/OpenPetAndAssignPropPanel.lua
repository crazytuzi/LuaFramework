local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPetAndAssignPropPanel = Lplus.Extend(Operation, CUR_CLASS_NAME)
local PetPanel = require("Main.Pet.ui.PetPanel")
local def = OpenPetAndAssignPropPanel.define
def.field("number").nodeId = PetPanel.NodeId.BasicNode
def.override("table", "=>", "boolean").Operate = function(self, params)
  local fightingPet = require("Main.Pet.Interface").GetFightingPet()
  if fightingPet then
    PetPanel.Instance().selectedPetId = fightingPet.id
    PetPanel.Instance():ShowPanelEx(self.nodeId)
    local PetAssignPropPanel = require("Main.Pet.ui.PetAssignPropPanel")
    PetAssignPropPanel.Instance():SetActivePet(fightingPet.id)
    PetAssignPropPanel.Instance():ShowPanel()
  else
    PetPanel.Instance():ShowPanelEx(self.nodeId)
  end
  return false
end
return OpenPetAndAssignPropPanel.Commit()
