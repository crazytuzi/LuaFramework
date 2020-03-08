local Lplus = require("Lplus")
local PetCfgData = Lplus.Class("PetCfgData")
local def = PetCfgData.define
def.field("number").templateId = 0
def.field("number").typeRefId = 0
def.field("number").modelId = 0
def.field("number").carryLevel = 0
def.field("number").petOpenIdipSwitch = 0
def.field("number").type = 0
def.field("number").colorId = 0
def.field("boolean").isCanBeHuaShengSubPet = false
def.field("boolean").isCanBeHuaShengMainPet = false
def.field("string").templateName = ""
def.field("string").shortName = ""
def.field("boolean").isSpecial = false
def.field("number").decorateItemId = 0
def.field("number").defaultAssignPointCfgId = 0
def.field("number").fanShengCfgId = 0
def.field("number").yaoliLevelId = 0
def.field("number").qualityStageRate = 0
def.field("number").growStageRate = 0
def.field("number").petScoreConfId = 0
def.field("number").changeModelCardClassType = 0
def.field("number").changeModelCardLevel = 0
def.field("table").minQualitys = nil
def.field("table").maxQualitys = nil
def.field("number").growMinValue = 0
def.field("number").growMaxValue = 0
def.field("number").skillPropTabId = 0
def.field("number").bornMaxLife = 0
def.field("number").buyPrice = 0
def.field("number").petFightModelRatio = 0
def.method("number", "=>", "dynamic").GetMinQuality = function(self, qualityType)
  return self.minQualitys[qualityType]
end
def.method("number", "=>", "dynamic").GetMaxQuality = function(self, qualityType)
  return self.maxQualitys[qualityType]
end
return PetCfgData.Commit()
