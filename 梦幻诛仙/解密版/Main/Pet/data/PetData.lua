local Lplus = require("Lplus")
local PetData = Lplus.Class("PetData")
local def = PetData.define
local PetQuality = require("Main.Pet.data.PetQuality")
local PetUtility = require("Main.Pet.PetUtility")
local PetCfgData = require("Main.Pet.data.PetCfgData")
local PetBaseProp = require("Main.Pet.data.PetBaseProp")
local PetSecondProp = require("Main.Pet.data.PetSecondProp")
local PetSoulProp = require("Main.Pet.soul.data.PetSoulProp")
local PetAssignPropScheme = require("Main.Pet.data.PetAssignPropScheme")
local PetInfo = require("netio.protocol.mzm.gsp.pet.PetInfo")
local PetSkillData = require("Main.Pet.data.PetSkillData")
local SkillModule = Lplus.ForwardDeclare("SkillModule")
local NOT_SET = -1
def.const("table").PetType = require("consts.mzm.gsp.pet.confbean.PetType")
def.const("table").PetQualityType = require("netio.protocol.mzm.gsp.pet.PetAptConsts")
def.const("table").PetEquipmentType = {
  EQUIP_HELMET = PetInfo.EQUIP_HELMET,
  EQUIP_NECKLACE = PetInfo.EQUIP_NECKLACE,
  EQUIP_AMULET = PetInfo.EQUIP_AMULET
}
def.const("number").NOT_SET = NOT_SET
def.field("userdata").id = nil
def.field("number").typeId = 0
def.field("string").name = ""
def.field("number").level = 0
def.field("number").life = 0
def.field("number").yaoli = 0
def.field("number").growValue = 0
def.field("number").hp = 0
def.field("number").mp = 0
def.field("number").exp = 0
def.field("userdata").marketbuytime = nil
def.field(PetBaseProp).baseProp = nil
def.field(PetSecondProp).secondProp = nil
def.field(PetAssignPropScheme).assignPropScheme = nil
def.field(PetSoulProp).soulProp = nil
def.field("number").rememberedSkillId = NOT_SET
def.field("boolean").isDecorated = false
def.field("boolean").isFighting = false
def.field("boolean").isDisplay = false
def.field("boolean").isCanResetProp = false
def.field("table").petQuality = nil
def.field("table").skillIdList = nil
def.field("table").equipments = nil
def.field("table").amuletSkillIdList = nil
def.field("table").combinedSkillIdList = nil
def.field("table").model = nil
def.field(PetCfgData).petCfgData = nil
def.field("boolean").isBinded = false
def.field("boolean").isEmpty = true
def.field("number").stageLevel = 0
def.field("number").extraModelCfgId = 0
def.field("table").extraModelList = nil
def.field("number").petMarkCfgId = 0
def.field("number").petMarkLevel = 0
def.field("table")._needExpCfg = nil
def.field("boolean")._needReCalcYaoLi = false
def.method("table").RawSet = function(self, data)
  self.id = data.petId
  self.typeId = data.typeId
  self.name = data.petName or "unknow"
  self.level = data.petLevel
  self.life = data.life
  self.yaoli = data.yaoli
  self.exp = data.exp
  self.growValue = tonumber(string.format("%.3f", data.grow))
  self.model = data.model
  self.hp = data.hp
  self.mp = data.mp
  self.marketbuytime = data.marketbuytime or Int64.new(0)
  self.isDecorated = data.isDecorated == 1
  self.isBinded = data.bindedState == 1
  self.isCanResetProp = data.isCanResetProp == 1
  self.rememberedSkillId = data.rememberSkillId
  self.petQuality = PetQuality()
  self.petQuality:RawSet(data.petApt)
  self.skillIdList = data.skillIdList or {}
  self.equipments = data.equipMap
  self:_GenAmuletSkillIdList()
  self:_GenCombinedSkillIdList()
  self.baseProp = PetBaseProp()
  self.baseProp:RawSet(data.basePropMap)
  self.secondProp = PetSecondProp()
  self.secondProp.maxHp = data.maxHp
  self.secondProp.maxMp = data.maxMp
  self.secondProp.phyAtk = data.phyAtk
  self.secondProp.phyDef = data.phyDef
  self.secondProp.magAtk = data.magAtk
  self.secondProp.magDef = data.magDef
  self.secondProp.speed = data.speed
  self.assignPropScheme = PetAssignPropScheme()
  self.assignPropScheme:RawSet(data)
  self.isEmpty = false
  self.stageLevel = data.stageLevel
  self.extraModelCfgId = data.extraModelCfgId
  self.extraModelList = {}
  for i = 1, #data.own_extra_model_cfg_ids do
    table.insert(self.extraModelList, data.own_extra_model_cfg_ids[i])
  end
  self.soulProp = PetSoulProp.New(self, data.soulMap)
  self.petMarkCfgId = data.petMarkCfgId
  self.petMarkLevel = data.petMarkLevel
end
def.method()._GenAmuletSkillIdList = function(self)
  self.amuletSkillIdList = {}
  local amuletItem = self.equipments[PetData.PetEquipmentType.EQUIP_AMULET]
  if amuletItem == nil then
    return
  end
  local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
  local indexList = {
    ItemXStoreType.PET_EQUIP_SKILL_ID_1,
    ItemXStoreType.PET_EQUIP_SKILL_ID_2
  }
  for i, index in ipairs(indexList) do
    local skillId = amuletItem.extraMap[index]
    if skillId then
      table.insert(self.amuletSkillIdList, skillId)
    end
  end
end
def.method()._GenCombinedSkillIdList = function(self)
  self.combinedSkillIdList = {}
  local skillIdMap = {}
  for i, skillId in ipairs(self.skillIdList) do
    skillIdMap[skillId] = true
    table.insert(self.combinedSkillIdList, skillId)
  end
  for i, skillId in ipairs(self.amuletSkillIdList) do
    if not skillIdMap[skillId] then
      table.insert(self.combinedSkillIdList, skillId)
    end
  end
end
def.method("=>", "table").GetSkillIdList = function(self)
  return self.skillIdList
end
def.method("=>", "table").GetAmuletSkillIdList = function(self)
  return self.amuletSkillIdList
end
def.method("=>", "table").GetCombinedSkillIdList = function(self)
  return self.combinedSkillIdList
end
def.method("=>", "table").GetConcatSkillIdList = function(self)
  if self.skillIdList == nil or self.amuletSkillIdList == nil then
    return nil
  end
  local list = {}
  for i, skillId in ipairs(self.skillIdList) do
    table.insert(list, skillId)
  end
  for i, skillId in ipairs(self.amuletSkillIdList) do
    table.insert(list, skillId)
  end
  return list
end
def.method("=>", "table").GetProtectMountsSkillIdList = function(self)
  local mountsSkillIdList = {}
  local MountsData = require("Main.Mounts.data.MountsData").Instance()
  local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
  local isprotected, mountsId = MountsMgr.Instance():IsPetProtected(self.id)
  if isprotected then
    local MountsUtils = require("Main.Mounts.MountsUtils")
    local mounts = MountsMgr.Instance():GetMountsById(mountsId)
    local passiveSkills = mounts.passive_skill_list
    local unlockSkillRank = MountsUtils.GetMountsSortedUnlockPassiveSkillRank(mounts.mounts_cfg_id)
    for i = 1, 3 do
      if unlockSkillRank[i] == nil then
      elseif passiveSkills[i] ~= nil and mounts.mounts_rank >= unlockSkillRank[i] then
        table.insert(mountsSkillIdList, passiveSkills[i].current_passive_skill_cfg_id)
      end
    end
  end
  return mountsSkillIdList
end
def.method("=>", PetCfgData).GetPetCfgData = function(self)
  if self.petCfgData == nil then
    self.petCfgData = PetUtility.Instance():GetPetCfg(self.typeId)
  end
  return self.petCfgData
end
def.method("=>", "boolean").IsNeverDie = function(self)
  if self.life == -1 then
    return true
  end
  return false
end
def.method("=>", "table").GetOnHookSkillIdList = function(self)
  local attckSkillId = SkillModule.NORMAL_ATTACK_SKILL_ID
  local defenseSkillId = SkillModule.DEFENCE_SKILL_ID
  local idList = {}
  table.insert(idList, attckSkillId)
  table.insert(idList, defenseSkillId)
  for i, skillId in ipairs(self.combinedSkillIdList) do
    local isNotPassiveSkill = not PetUtility.IsPassiveSkill(skillId)
    if isNotPassiveSkill then
      table.insert(idList, skillId)
    end
  end
  return idList
end
def.method("=>", "table").GetPetSkillList = function(self)
  local attckSkillId = SkillModule.NORMAL_ATTACK_SKILL_ID
  local defenseSkillId = SkillModule.DEFENCE_SKILL_ID
  local attckSkill = PetSkillData()
  attckSkill.id = attckSkillId
  attckSkill.isBasicSkill = true
  local defenseSkill = PetSkillData()
  defenseSkill.id = defenseSkillId
  defenseSkill.isBasicSkill = true
  local skillList = {}
  table.insert(skillList, attckSkill)
  table.insert(skillList, defenseSkill)
  for i, skillId in ipairs(self.combinedSkillIdList) do
    local skill = PetSkillData()
    skill.id = skillId
    skill.level = self.level
    if PetUtility.IsPassiveSkill(skill.id) then
      skill.isPassiveSkill = true
    end
    table.insert(skillList, skill)
  end
  return skillList
end
def.method("=>", "number").GetLevelUpNeededExp = function(self)
  if self._needExpCfg == nil or self._needExpCfg.curLevel ~= self.level then
    self._needExpCfg = self._needExpCfg or {}
    self._needExpCfg.curLevel = self.level
    self._needExpCfg.neededExp = PetUtility.GetPetLevelUpExp(self.level + 1)
  end
  local neededExp = self._needExpCfg.neededExp or 0
  return neededExp
end
def.method().ReCalcYaoLi = function(self)
  self._needReCalcYaoLi = true
end
def.method("=>", "number").GetYaoLi = function(self)
  if self._needReCalcYaoLi then
    self.yaoli = PetUtility.CalcPetYaoLi(self)
    self._needReCalcYaoLi = false
  end
  return self.yaoli
end
def.method("=>", "boolean").IsSpecial = function(self)
  local petCfg = self:GetPetCfgData()
  return petCfg.isSpecial
end
def.method("=>", "boolean").IsBinded = function(self)
  return self.isBinded
end
def.method("=>", "string").GetHeadIconBGSpriteName = function(self)
  local petCfg = self:GetPetCfgData()
  local score = self:GetLevelScore()
  return PetUtility.GetHeadIconBGSpriteName(petCfg, score)
end
def.method("=>", "number").GetHeadIconId = function(self)
  local petCfg = self:GetPetCfgData()
  local modelCfg = require("Main.Pubrole.PubroleInterface").GetModelCfg(petCfg.modelId)
  return modelCfg.headerIconId
end
def.method("=>", "number").GetModelId = function(self)
  local petCfg = self:GetPetCfgData()
  return petCfg.modelId
end
def.method("=>", "boolean").CanAssignProp = function(self)
  return self.assignPropScheme.potentialPoint > 0
end
def.method("=>", "boolean").NeedAssignProp = function(self)
  if self.assignPropScheme.potentialPoint > 0 and not self.assignPropScheme.isEnableAutoAssign then
    return true
  end
  return false
end
def.method("=>", "boolean").HasRememberdSkill = function(self)
  return self.rememberedSkillId ~= NOT_SET
end
def.method("=>", "table").GetPetYaoLiCfg = function(self)
  local score = self:GetLevelScore()
  local cfgData = self:GetPetCfgData()
  return PetUtility.Instance():GetPetYaoLiCfg(cfgData.yaoliLevelId, score)
end
def.method("=>", "number").GetYaoLiLevel = function(self)
  local cfg = self:GetPetYaoLiCfg()
  return cfg.petYaoLiLevel
end
def.method("=>", "number").GetLevelScore = function(self)
  local cfgData = self:GetPetCfgData()
  local levelScoreCfg = PetUtility.Instance():GetPetLevelScoreCfg(cfgData.petScoreConfId)
  if levelScoreCfg == nil then
    return 0
  end
  local qualitySum = self.petQuality:GetQualitySum()
  local growValue = self.growValue
  local _ = levelScoreCfg
  local score = _.param1Rate * (qualitySum - _.minAptRate + 1) / (_.maxAptRate - _.minAptRate + 1) + _.param2Rate * (growValue * _G.NUMBER_WAN - _.minGrowRate + 1) / (_.maxGrowRate - _.minGrowRate + 1)
  score = require("Common.MathHelper").Floor(score)
  return score
end
def.method("=>", "boolean").IsRarity = function(self)
  local score = self:GetLevelScore()
  return PetUtility.IsRarityPet(self.typeId, score) or _G._DEBUG_MARKET or false
end
def.method("=>", "boolean").CanChongSheng = function(self)
  local petCfgData = self:GetPetCfgData()
  return petCfgData.type == PetData.PetType.SHENSHOU or petCfgData.type == PetData.PetType.MOSHOU
end
def.method("=>", "boolean").IsSkillSameWithOrigin = function(self)
  local petCfg = self:GetPetCfgData()
  local skillcfgList = require("Main.Skill.SkillUtility").GetMonsterSkillCfg(petCfg.skillPropTabId)
  if #self.skillIdList ~= #skillcfgList then
    return false
  end
  local skillCfgMap = {}
  for i = 1, #skillcfgList do
    local cfgId = skillcfgList[i]
    skillCfgMap[cfgId] = true
  end
  for i = 1, #self.skillIdList do
    local skillId = self.skillIdList[i]
    if skillCfgMap[skillId] ~= true then
      return false
    end
  end
  return true
end
def.method("=>", "boolean").CanJinjie = function(self)
  local petCfgData = self:GetPetCfgData()
  if petCfgData == nil then
    return false
  end
  return PetUtility.GetPetJinjieCfgByPetId(petCfgData.templateId) ~= nil
end
def.method("number", "=>", "boolean").HasSkill = function(self, skillId)
  if self.skillIdList == nil then
    return false
  end
  for idx, id in pairs(self.skillIdList) do
    if id == skillId then
      return true
    end
  end
  return false
end
def.method("=>", "number").GetPetDisplayMarkModelId = function(self)
  local isPetMarkOpen = require("Main.Pet.PetMark.PetMarkMgr").Instance():IsFeatureOpen()
  if not isPetMarkOpen then
    return 0
  end
  if 0 >= self.petMarkCfgId then
    return 0
  else
    local markCfg = require("Main.Pet.PetMark.PetMarkUtils").GetPetMarkCfg(self.petMarkCfgId)
    if markCfg == nil then
      return 0
    else
      return markCfg.modelId
    end
  end
end
def.method("=>", "number").GetPetMarkLevel = function(self)
  return self.petMarkLevel
end
def.method("=>", "number").GetPetMarkCfgId = function(self)
  return self.petMarkCfgId
end
def.method("=>", "number").GetPetMarkSkillId = function(self)
  local isPetMarkOpen = require("Main.Pet.PetMark.PetMarkMgr").Instance():IsFeatureOpen()
  if not isPetMarkOpen then
    return 0
  end
  if 0 >= self.petMarkCfgId then
    return 0
  else
    local levelCfg = require("Main.Pet.PetMark.PetMarkUtils").GetPetMarkLevelCfgByLevel(self.petMarkCfgId, self.petMarkLevel)
    if levelCfg == nil then
      return 0
    else
      return levelCfg.passiveSkillId
    end
  end
end
def.method("=>", "table").GetSortedExtraModelList = function(self)
  local list = {}
  if self.extraModelCfgId ~= 0 then
    table.insert(list, self.extraModelCfgId)
  end
  for i = #self.extraModelList, 1, -1 do
    if self.extraModelList[i] ~= self.extraModelCfgId then
      table.insert(list, self.extraModelList[i])
    end
  end
  return list
end
def.method("number").SwitchToExtraModel = function(self, extraModelId)
  if extraModelId == self.extraModelCfgId then
    return
  end
  self.extraModelCfgId = extraModelId
end
def.method("number").DeleteExtraModel = function(self, extraModelId)
  if extraModelId == self.extraModelCfgId then
    self.extraModelCfgId = 0
  end
  for i = 1, #self.extraModelList do
    if self.extraModelList[i] == extraModelId then
      table.remove(self.extraModelList, i)
      break
    end
  end
end
def.method("number", "=>", "boolean").HasExtraModel = function(self, extraModelCfgId)
  if self.extraModelCfgId == extraModelCfgId then
    return true
  end
  for i = 1, #self.extraModelList do
    if self.extraModelList[i] == extraModelCfgId then
      return true
    end
  end
  return false
end
def.method("=>", "boolean").HasAnyExtraModel = function(self)
  if self.extraModelCfgId ~= 0 then
    return true
  end
  if 0 < #self.extraModelList then
    return true
  end
  return false
end
def.method("=>", "boolean").IsFullExtraModel = function(self)
  local maxModelCount = PetUtility.Instance():GetPetConstants("OWN_MAX_EXTRA_MODEL_NUM")
  return maxModelCount <= #self.extraModelList
end
return PetData.Commit()
