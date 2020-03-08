local Lplus = require("Lplus")
local PetMarkInfo = Lplus.Class("PetMarkInfo")
local def = PetMarkInfo.define
def.field("userdata").id = nil
def.field("number").petMarkCfgId = 0
def.field("number").level = 0
def.field("number").exp = 0
def.field("userdata").petId = nil
def.method("userdata", "table").RawSet = function(self, id, data)
  self.id = id
  self.petMarkCfgId = data.pet_mark_cfg_id
  self.level = data.level
  self.exp = data.exp
  self.petId = data.pet_id
end
def.method("=>", "userdata").GetId = function(self)
  return self.id
end
def.method("=>", "number").GetPetMarkCfgId = function(self)
  return self.petMarkCfgId
end
def.method("number").SetPetMarkCfgId = function(self, cfgId)
  self.petMarkCfgId = cfgId
end
def.method("=>", "number").GetLevel = function(self)
  return self.level
end
def.method("number").SetLevel = function(self, level)
  self.level = level
end
def.method("=>", "number").GetExp = function(self)
  return self.exp
end
def.method("number").SetExp = function(self, exp)
  self.exp = exp
end
def.method("=>", "userdata").GetPetId = function(self)
  return self.petId
end
def.method("userdata").SetPetId = function(self, petId)
  self.petId = petId
end
def.method("=>", "boolean").HasEquipPet = function(self)
  if self.petId == nil then
    return false
  else
    return Int64.gt(self.petId, 0)
  end
end
def.method("=>", "boolean").IsFullLevel = function(self)
  if self.level >= constant.CPetMarkConstants.PET_MARK_MAX_LEVEL then
    return true
  end
  local PetMarkUtils = require("Main.Pet.PetMark.PetMarkUtils")
  local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(self.petMarkCfgId)
  if allLevelCfg == nil then
    return true
  else
    return allLevelCfg.levelCfg[self.level + 1] == nil
  end
end
def.method("=>", "number").GetLevelUpNeedHeroLevel = function(self)
  if self.level >= constant.CPetMarkConstants.PET_MARK_MAX_LEVEL then
    return -1
  end
  local PetMarkUtils = require("Main.Pet.PetMark.PetMarkUtils")
  local allLevelCfg = PetMarkUtils.GetPetMarkLevelCfg(self.petMarkCfgId)
  if allLevelCfg == nil or allLevelCfg.levelCfg[self.level + 1] == nil then
    return -1
  else
    return allLevelCfg.levelCfg[self.level + 1].needRoleLevel
  end
end
PetMarkInfo.Commit()
return PetMarkInfo
