local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local OpenPetTuJianSpeBaoBao = Lplus.Extend(Operation, CUR_CLASS_NAME)
local def = OpenPetTuJianSpeBaoBao.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
  local petType = PetType.BAOBAO
  local carrayLevel = params[3] and tonumber(params[3]) or 0
  require("Main.Pet.ui.PetTuJianPanel").Instance():ShowPanelWithPetDetail({carrayLevel = carrayLevel, type = petType})
  return false
end
return OpenPetTuJianSpeBaoBao.Commit()
