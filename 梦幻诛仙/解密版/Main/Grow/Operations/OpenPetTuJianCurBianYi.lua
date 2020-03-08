local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPetTuJianCurBianYi = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenPetTuJianCurBianYi.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
  local petType = PetType.BIANYI
  local carrayLevel = _G.GetHeroProp().level
  require("Main.Pet.ui.PetTuJianPanel").Instance():ShowPanelWithPetDetail({carrayLevel = carrayLevel, type = petType})
  return false
end
return OpenPetTuJianCurBianYi.Commit()
