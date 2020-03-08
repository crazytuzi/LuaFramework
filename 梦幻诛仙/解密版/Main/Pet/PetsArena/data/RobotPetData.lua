local Lplus = require("Lplus")
local RobotPetData = Lplus.Class("RobotPetData")
local def = RobotPetData.define
def.field("number").id = 0
def.field("number").level = 0
def.field("number").grade = 0
def.field("number").score = 0
def.field("number")._petFightModelRatio = 10000
def.field("boolean").bIsRobot = true
def.method("table").RawSet = function(self, data)
  self.id = data.monster_cfgid
  self._petFightModelRatio = data.model_ratio
  self.level = data.level
  self.grade = data.grade
  self.score = data.score
end
def.method("=>", "table").GetPetCfgData = function(self)
  return {
    petFightModelRatio = self._petFightModelRatio
  }
end
def.method("=>", "number").GetYaoLi = function(self)
  return self.score
end
def.method("=>", "table").GetPetYaoLiCfg = function(self)
  local PetYaoLi = require("consts.mzm.gsp.pet.confbean.PetYaoLi")
  local cfg = {
    petYaoLiLevel = self.grade
  }
  local encodeChar = PetYaoLi.SSS
  if cfg.petYaoLiLevel >= PetYaoLi.A then
    encodeChar = string.char(65 + cfg.petYaoLiLevel - PetYaoLi.A)
  elseif cfg.petYaoLiLevel == PetYaoLi.S then
    encodeChar = string.char(83)
  elseif cfg.petYaoLiLevel == PetYaoLi.SS then
    encodeChar = string.char(84)
  elseif cfg.petYaoLiLevel == PetYaoLi.SSS then
    encodeChar = string.char(85)
  end
  cfg.encodeChar = encodeChar
  return cfg
end
return RobotPetData.Commit()
