local Lplus = require("Lplus")
local PetAssignPropMgr = Lplus.Class("PetAssignPropMgr")
local def = PetAssignPropMgr.define
local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
local PetData = require("Main.Pet.data.PetData")
local PetQualityType = PetData.PetQualityType
local PetUtility = require("Main.Pet.PetUtility")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
def.const("table").basePropMap = {
  str = PropertyType.STR,
  dex = PropertyType.DEX,
  con = PropertyType.CON,
  sta = PropertyType.STA,
  spi = PropertyType.SPR
}
def.const("table").secondPropMap = {
  maxHp = PropertyType.MAX_HP,
  maxMp = PropertyType.MAX_MP,
  phyAtk = PropertyType.PHYATK,
  phyDef = PropertyType.PHYDEF,
  magAtk = PropertyType.MAGATK,
  magDef = PropertyType.MAGDEF,
  speed = PropertyType.SPEED
}
def.const("table").secondPropQualityMap = {
  maxHp = PetQualityType.HP_APT,
  maxMp = nil,
  phyAtk = PetQualityType.PHYATK_APT,
  phyDef = PetQualityType.PHYDEF_APT,
  magAtk = PetQualityType.MAGATK_APT,
  magDef = PetQualityType.MAGDEF_APT,
  speed = PetQualityType.SPEED_APT
}
def.field("table").propTransCfgCatched = nil
local instance
def.static("=>", PetAssignPropMgr).Instance = function()
  if instance == nil then
    instance = PetAssignPropMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method("userdata", "string").IncBaseProp = function(self, petId, attr)
  local pet = PetMgr:GetPet(petId)
  local scheme = pet.assignPropScheme
  local manualAssigning = scheme:GetManualAssigning()
  if scheme.manualAssignedPoint >= scheme.potentialPoint then
    return
  end
  manualAssigning[attr] = manualAssigning[attr] + 1
  scheme.manualAssignedPoint = scheme.manualAssignedPoint + 1
  self:CalcSecondProp(pet)
end
def.method("userdata", "string").DecBaseProp = function(self, petId, attr)
  local pet = PetMgr:GetPet(petId)
  local scheme = pet.assignPropScheme
  local manualAssigning = scheme:GetManualAssigning()
  if manualAssigning[attr] <= 0 then
    return
  end
  manualAssigning[attr] = manualAssigning[attr] - 1
  scheme.manualAssignedPoint = scheme.manualAssignedPoint - 1
  self:CalcSecondProp(pet)
end
def.method("userdata", "string", "number", "=>", "number").SetBaseProp = function(self, petId, propName, value)
  local pet = PetMgr:GetPet(petId)
  local scheme = pet.assignPropScheme
  local manualAssigning = scheme:GetManualAssigning()
  local actualValue = value
  local preValue = scheme.manualAssigning[propName]
  if scheme.manualAssignedPoint + value - preValue > scheme.potentialPoint then
    actualValue = scheme.potentialPoint - scheme.manualAssignedPoint + preValue
  end
  scheme.manualAssigning[propName] = actualValue
  scheme.manualAssignedPoint = scheme.manualAssignedPoint + scheme.manualAssigning[propName] - preValue
  self:CalcSecondProp(pet)
  return actualValue
end
def.method("userdata", "=>", "number").GetUnusedPotentialPointNum = function(self, petId)
  local pet = PetMgr:GetPet(petId)
  return pet.assignPropScheme.potentialPoint - pet.assignPropScheme.manualAssignedPoint
end
def.method("table").CalcSecondProp = function(self, pet)
  self:CalcPropAddon(pet)
  local scheme = pet.assignPropScheme
  local petQuality = pet.petQuality
  for secondKey, _ in pairs(PetAssignPropMgr.secondPropMap) do
    scheme.secondPropPreview[secondKey] = 0
  end
  for baseKey, baseIndex in pairs(PetAssignPropMgr.basePropMap) do
    for secondKey, secondIndex in pairs(PetAssignPropMgr.secondPropMap) do
      local qualityType = PetAssignPropMgr.secondPropQualityMap[secondKey]
      local transformValue = self:GetTransformValue(baseKey, secondKey)
      local qualityValue = 1
      if qualityType then
        qualityValue = petQuality:GetQuality(qualityType)
      end
      local secondPropValue = scheme.manualAssigning[baseKey] * transformValue * pet.growValue
      scheme.secondPropPreview[secondKey] = scheme.secondPropPreview[secondKey] + secondPropValue
    end
  end
  for secondKey, secondIndex in pairs(PetAssignPropMgr.secondPropMap) do
    scheme.secondPropPreview[secondKey] = require("Common.MathHelper").Round(scheme.secondPropPreview[secondKey])
  end
end
def.method("table").CalcPropAddon = function(self, pet)
  local scheme = pet.assignPropScheme
  scheme.secondPropPreview = scheme.secondPropPreview or HeroSecondProp()
  for secondKey, secondIndex in pairs(PetAssignPropMgr.secondPropMap) do
    local addon = 0
    for baseKey, baseIndex in pairs(PetAssignPropMgr.basePropMap) do
      local transformValue = self:GetTransformValue(baseKey, secondKey)
      local pre = pet.baseProp[baseKey] * transformValue
      addon = addon + pre
    end
    addon = addon - require("Common.MathHelper").Floor(addon)
    scheme.secondPropPreview[secondKey] = addon
  end
end
def.method("string", "string", "=>", "number").GetTransformValue = function(self, baseKey, secondKey)
  if self.propTransCfgCatched == nil then
    self.propTransCfgCatched = PetUtility.Instance():GetPetPropTransCfg()
  end
  local selectedBase = PetAssignPropMgr.basePropMap[baseKey]
  local selectedSecond = PetAssignPropMgr.secondPropMap[secondKey]
  local propKey = PetUtility.Instance():GenPropKey(selectedBase, selectedSecond)
  local value
  if self.propTransCfgCatched[propKey] then
    value = self.propTransCfgCatched[propKey].bp2fpFactor
  else
    value = 0
  end
  return value
end
def.method("userdata", "string").IncBasePropPrefab = function(self, petId, attr)
  local pet = PetMgr:GetPet(petId)
  local scheme = pet.assignPropScheme
  local autoAssigning = scheme:GetAutoAssigning()
  if scheme.autoAssignedPoint >= scheme.autoAssignPointLimit then
    return
  end
  autoAssigning[attr] = autoAssigning[attr] + 1
  scheme.autoAssignedPoint = scheme.autoAssignedPoint + 1
end
def.method("userdata", "string").DecBasePropPrefab = function(self, petId, attr)
  local pet = PetMgr:GetPet(petId)
  local scheme = pet.assignPropScheme
  local autoAssigning = scheme:GetAutoAssigning()
  if autoAssigning[attr] <= 0 then
    return
  end
  autoAssigning[attr] = autoAssigning[attr] - 1
  scheme.autoAssignedPoint = scheme.autoAssignedPoint - 1
end
def.method("userdata", "string", "number", "=>", "number").SetBasePropSetting = function(self, petId, propName, value)
  local pet = PetMgr:GetPet(petId)
  local scheme = pet.assignPropScheme
  local autoAssigning = scheme:GetAutoAssigning()
  local actualValue = value
  local preValue = scheme.autoAssigning[propName]
  if scheme.autoAssignedPoint + value - preValue > scheme.autoAssignPointLimit then
    actualValue = scheme.autoAssignPointLimit - scheme.autoAssignedPoint + preValue
  end
  scheme.autoAssigning[propName] = actualValue
  scheme.autoAssignedPoint = scheme.autoAssignedPoint + scheme.autoAssigning[propName] - preValue
  return actualValue
end
def.method("userdata", "=>", "number").GetUnusedPrefabPointNum = function(self, petId)
  local pet = PetMgr:GetPet(petId)
  return pet.assignPropScheme.autoAssignPointLimit - pet.assignPropScheme.autoAssignedPoint
end
def.method("userdata", "number").ResetPotentialPoint = function(self, petId, itemNum)
  local ItemModule = require("Main.Item.ItemModule")
  local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
  self:C2S_ResetPotentialPoint(petId, itemNum, yuanBaoNum)
end
def.method("userdata").SaveAssignedProp = function(self, petId)
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local pet = PetMgr:GetPet(petId)
  local manualAssigning = pet.assignPropScheme:GetManualAssigning()
  local assignPropMap = {
    [PropertyType.STR] = manualAssigning.str,
    [PropertyType.DEX] = manualAssigning.dex,
    [PropertyType.CON] = manualAssigning.con,
    [PropertyType.STA] = manualAssigning.sta,
    [PropertyType.SPR] = manualAssigning.spi
  }
  self:C2S_AssignProp(petId, assignPropMap)
end
def.method("userdata").SaveAssignedPropPrefab = function(self, petId)
  local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
  local pet = PetMgr:GetPet(petId)
  local autoAssigning = pet.assignPropScheme:GetAutoAssigning()
  local assignPropMap = {
    [PropertyType.STR] = autoAssigning.str,
    [PropertyType.DEX] = autoAssigning.dex,
    [PropertyType.CON] = autoAssigning.con,
    [PropertyType.STA] = autoAssigning.sta,
    [PropertyType.SPR] = autoAssigning.spi
  }
  self:C2S_AssignPrefab(petId, assignPropMap)
end
def.method("userdata").ToggleAutoAssignState = function(self, petId)
  local pet = PetMgr:GetPet(petId)
  local scheme = pet.assignPropScheme
  local targetState = not scheme.isEnableAutoAssign
  self:EnableAutoAssign(targetState)
end
def.method("userdata", "boolean").EnableAutoAssign = function(self, petId, isEnable)
  local pet = PetMgr:GetPet(petId)
  local scheme = pet.assignPropScheme
  if scheme.isEnableAutoAssign == isEnable then
    return
  end
  local stateValue
  if isEnable then
    stateValue = 1
  else
    stateValue = 0
  end
  self:C2S_SetAutoAssignPropState(petId, stateValue)
end
def.method("table").OnSAutoAddPotentialPrefRes = function(self, data)
  local pet = PetMgr:GetPet(data.petId)
  pet.assignPropScheme.autoAssigned.str = data.propMap[PropertyType.STR]
  pet.assignPropScheme.autoAssigned.dex = data.propMap[PropertyType.DEX]
  pet.assignPropScheme.autoAssigned.con = data.propMap[PropertyType.CON]
  pet.assignPropScheme.autoAssigned.sta = data.propMap[PropertyType.STA]
  pet.assignPropScheme.autoAssigned.spi = data.propMap[PropertyType.SPR]
  pet.assignPropScheme:ResetAutoAssigning()
  Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SAVE_ASSIGN_PROP_PREFAB_SUCCESS, {
    data.petId
  })
end
def.method("userdata", "number", "userdata").C2S_ResetPotentialPoint = function(self, petId, itemNum, yuanBaoNum)
  local p = require("netio.protocol.mzm.gsp.pet.CResetPotentialReq").new(petId, itemNum, yuanBaoNum)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "table").C2S_AssignProp = function(self, petId, propMap)
  local p = require("netio.protocol.mzm.gsp.pet.CDiyPotentialReq").new(petId, propMap)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "number").C2S_SetAutoAssignPropState = function(self, petId, state)
  local p = require("netio.protocol.mzm.gsp.pet.CSetAutoAddFlag").new(petId, state)
  gmodule.network.sendProtocol(p)
end
def.method("userdata", "table").C2S_AssignPrefab = function(self, petId, propMap)
  local p = require("netio.protocol.mzm.gsp.pet.CAutoAddPotentialPrefReq").new(petId, propMap)
  gmodule.network.sendProtocol(p)
end
return PetAssignPropMgr.Commit()
