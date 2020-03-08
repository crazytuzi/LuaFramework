local Lplus = require("Lplus")
local PetTeamData = require("Main.PetTeam.data.PetTeamData")
local PetTeamInfo = require("Main.PetTeam.data.PetTeamInfo")
local PetTeamInterface = Lplus.Class("PetTeamInterface")
local def = PetTeamInterface.define
def.static("number", "=>", PetTeamInfo).GetPetTeamInfo = function(teamIdx)
  return PetTeamData.Instance():GetTeamInfo(teamIdx)
end
def.static("number", "=>", "table").GetFormationCfg = function(formationId)
  return PetTeamData.Instance():GetFormationCfg(formationId)
end
def.static("=>", "number").GetDefTeamIdx = function()
  return PetTeamData.Instance():GetDefTeamIdx()
end
PetTeamInterface.Commit()
return PetTeamInterface
