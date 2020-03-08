local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local SkillTipMgr = Lplus.Class("SkillTipMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local SkillData = require("Main.Skill.data.SkillData")
local SkillMgr = require("Main.Skill.SkillMgr")
local SkillModule = require("Main.Skill.SkillModule")
local SkillUseType = require("consts.mzm.gsp.skill.confbean.CostType")
local ConditionType = require("consts.mzm.gsp.skill.confbean.ConditionType")
local Formulation = require("Main.Common.Formulation")
local def = SkillTipMgr.define
def.field("table")._operations = nil
local instance
def.static("=>", SkillTipMgr).Instance = function()
  if instance == nil then
    instance = SkillTipMgr()
    instance:InitOperations()
  end
  return instance
end
def.method().InitOperations = function(self)
  self._operations = {
    import(".operations.RememberSkill", CUR_CLASS_NAME),
    import(".operations.UnrememberSkill", CUR_CLASS_NAME),
    import(".operations.SetGoalWingSkill", CUR_CLASS_NAME),
    import(".operations.UnsetTargetWingSkill", CUR_CLASS_NAME)
  }
end
def.method("table", "=>", "table").GetOperations = function(self, context)
  local opes = {}
  for k, v in ipairs(self._operations) do
    local ope = v()
    ope.context = context
    if ope:CanDispaly(context) then
      table.insert(opes, ope)
    end
  end
  return opes
end
def.method(SkillData, "number", "number", "number", "number", "number").ShowTip = function(self, skillData, sourceX, sourceY, sourceW, sourceH, prefer)
  if skillData:IsEnchantingSkill() then
    self:ShowEnchantingTip(skillData, sourceX, sourceY, sourceW, sourceH, prefer)
    return
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillData.id)
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local level = skillData.level
  local description = skillCfg.description
  local typeText = textRes.Skill.SkillType[skillCfg.type]
  local isUnlock = skillData:IsUnlock()
  local unlockTip = ""
  if not isUnlock then
    local skillBagCfg = SkillUtility.GetSkillBagCfg(skillData.bagId)
    unlockTip = string.format(textRes.Skill[6], skillBagCfg.name, skillData.unlockLevel)
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local costInfo = self:GetSkillCostInfo(skillCfg.conditionId, skillData.level, heroProp.level)
  local consume = self:GetFormatCostText(costInfo)
  require("GUI.CommonSkillTip").Instance():ShowPanel(iconId, name, level, description, typeText, consume, isUnlock, unlockTip, sourceX, sourceY, sourceW, sourceH, prefer)
end
def.method("number", "userdata", "number").ShowTipByIdEx = function(self, skillId, go, prefer)
  if not go then
    return
  end
  local position = go.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  if not widget then
    warn("There is no widget component in :", go.name)
    return
  end
  self:ShowTipById(skillId, screenPos.x, screenPos.y, widget.width, widget.height, prefer)
end
def.method("number", "userdata", "number", "table").ShowTipByIdExWithOperates = function(self, skillId, go, prefer, context)
  if not go then
    return
  end
  local position = go.position
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = go:GetComponent("UIWidget")
  if not widget then
    warn("There is no widget component in :", go.name)
    return
  end
  self:ShowTipByIdWithOpe(skillId, screenPos.x, screenPos.y, widget.width, widget.height, prefer, context)
end
def.method("number", "number", "number", "number", "number", "number", "table").ShowTipByIdWithOpe = function(self, skillId, sourceX, sourceY, sourceW, sourceH, prefer, context)
  if SkillUtility.IsEnchantingSkill(skillId) then
    self:ShowEnchantingTipById(skillId, sourceX, sourceY, sourceW, sourceH, prefer)
    return
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local description = skillCfg.description
  local isUnlock = true
  local unlockTip = ""
  local typeText, consume
  if SkillUtility.IsPassiveSkill(skillId) then
    typeText = textRes.Pet.SkillType[2]
    consume = textRes.Skill[8]
  else
    typeText = textRes.Pet.SkillType[1]
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local costInfo = self:GetSkillCostInfo(skillCfg.conditionId, 1, heroProp.level)
    consume = self:GetFormatCostText(costInfo)
  end
  local pos = {
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  if context ~= nil then
    local operations = self:GetOperations(context)
    require("GUI.CommonSkillTip").Instance():ShowSimplePanel(iconId, name, description, typeText, consume, isUnlock, unlockTip, pos, operations)
  else
    require("GUI.CommonSkillTip").Instance():ShowSimplePanel(iconId, name, description, typeText, consume, isUnlock, unlockTip, pos, nil)
  end
end
def.method("number", "number", "number", "number", "number", "number").ShowTipById = function(self, skillId, sourceX, sourceY, sourceW, sourceH, prefer)
  if SkillUtility.IsEnchantingSkill(skillId) then
    self:ShowEnchantingTipById(skillId, sourceX, sourceY, sourceW, sourceH, prefer)
    return
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local description = skillCfg.description
  local isUnlock = true
  local unlockTip = ""
  local typeText, consume
  if SkillUtility.IsPassiveSkill(skillId) then
    typeText = textRes.Pet.SkillType[2]
    consume = textRes.Skill[8]
  else
    typeText = textRes.Pet.SkillType[1]
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local costInfo = self:GetSkillCostInfo(skillCfg.conditionId, 1, heroProp.level)
    consume = self:GetFormatCostText(costInfo)
  end
  local pos = {
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  require("GUI.CommonSkillTip").Instance():ShowSimplePanel(iconId, name, description, typeText, consume, isUnlock, unlockTip, pos, nil)
end
def.method("number", "number", "number", "number", "number", "number", "number", "userdata").ShowChildSkillTip = function(self, skillId, sourceX, sourceY, sourceW, sourceH, prefer, menpai, childId)
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local description = skillCfg.description
  local isUnlock = true
  local unlockTip = ""
  local menpaiSkillMap = require("Main.Children.ChildrenUtils").GetMenpaiSkillMap(menpai)
  local child_data = require("Main.Children.ChildrenDataMgr").Instance():GetChildById(childId)
  if menpaiSkillMap and menpaiSkillMap[skillId] and child_data then
    local childEquipLv = child_data:GetEquipsMinLevel()
    local skillCfgInfo = menpaiSkillMap[skillId]
    if childEquipLv < skillCfgInfo.needEquipmentLevel then
      isUnlock = false
      unlockTip = string.format(textRes.Children[34], skillCfgInfo.needEquipmentLevel)
    end
  end
  local typeText, consume
  if SkillUtility.IsPassiveSkill(skillId) then
    typeText = textRes.Pet.SkillType[2]
    consume = textRes.Skill[8]
  else
    typeText = textRes.Pet.SkillType[1]
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local costInfo = self:GetSkillCostInfo(skillCfg.conditionId, 1, heroProp.level)
    consume = self:GetFormatCostText(costInfo)
  end
  local pos = {
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  require("GUI.CommonSkillTip").Instance():ShowSimplePanel(iconId, name, description, typeText, consume, isUnlock, unlockTip, pos, nil)
end
def.method(SkillData, "number", "number", "number", "number", "number").ShowEnchantingTip = function(self, skillData, sourceX, sourceY, sourceW, sourceH, prefer)
  local skillCfg = SkillUtility.GetEnchantingSkillCfg(skillData.id)
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local level = skillData.level
  local description = skillCfg.description
  local typeText = textRes.Skill.SkillType[100]
  local isUnlock = skillData:IsUnlock()
  local unlockTip = ""
  if not isUnlock then
    local skillBagCfg = SkillUtility.GetSkillBagCfg(skillData.bagId)
    unlockTip = string.format(textRes.Skill[6], skillBagCfg.name, skillData.unlockLevel)
  end
  local consumeValue = SkillMgr.Instance():GetFormulaResult(skillCfg.costFormulaId, level)
  local consume = string.format(textRes.Skill.SkillUseType[100], consumeValue)
  require("GUI.CommonSkillTip").Instance():ShowPanel(iconId, name, level, description, typeText, consume, isUnlock, unlockTip, sourceX, sourceY, sourceW, sourceH, prefer)
end
def.method("number", "number", "number", "number", "number", "number").ShowEnchantingTipById = function(self, skillId, sourceX, sourceY, sourceW, sourceH, prefer)
  local skillData = SkillData()
  skillData.id = skillId
  skillData.level = _G.GetHeroProp().level
  self:ShowEnchantingTip(skillData, sourceX, sourceY, sourceW, sourceH, prefer)
end
def.method("number", "number", "number", "number", "number", "number").ShowPetTip = function(self, skillId, sourceX, sourceY, sourceW, sourceH, prefer)
  local level = _G.GetHeroProp().level
  self:ShowPetTipEx(skillId, level, sourceX, sourceY, sourceW, sourceH, prefer, nil)
end
def.method("number", "number", "number", "number", "number", "number", "number", "table").ShowPetTipEx = function(self, skillId, level, sourceX, sourceY, sourceW, sourceH, prefer, context)
  local PetUtility = require("Main.Pet.PetUtility")
  local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local description = skillCfg.description
  local isUnlock = true
  local unlockTip = ""
  local typeText, consume
  if PetUtility.IsPassiveSkill(skillId) then
    typeText = textRes.Pet.SkillType[2]
    consume = textRes.Skill[8]
  else
    typeText = textRes.Pet.SkillType[1]
    local costInfo = self:GetSkillCostInfo(skillCfg.conditionId, level, level)
    consume = self:GetFormatCostText(costInfo)
  end
  local pos = {
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local operations = self:GetOperations(context)
  require("GUI.CommonSkillTip").Instance():ShowSimplePanel(iconId, name, description, typeText, consume, isUnlock, unlockTip, pos, operations)
end
def.method("number", "number", "number", "number", "number", "number", "table").ShowFightPetSkillTip = function(self, petSkillId, sourceX, sourceY, sourceW, sourceH, prefer, context)
  local PetUtility = require("Main.Pet.PetUtility")
  local PetTeamData = require("Main.PetTeam.data.PetTeamData")
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local petSkillCfg = PetTeamData.Instance():GetSkillCfg(petSkillId)
  if nil == petSkillCfg then
    warn("[ERROR][SkillTipMgr:ShowFightPetSkillTip] petSkillCfg nil for:", petSkillId)
    return
  end
  local skillCfg = PetUtility.Instance():GetPetSkillCfg(petSkillCfg.skillId)
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local description = skillCfg.description
  local petId = PetTeamData.Instance():GetSkillPet(petSkillId)
  local petInfo = petId and PetMgr.Instance():GetPet(petId)
  if petInfo then
    local surfix = string.format(textRes.PetTeam.SKILL_USING, petInfo.name)
    if description then
      description = description .. surfix
    else
      description = surfix
    end
  end
  local isUnlock = true
  local unlockTip = ""
  local typeText, consume
  if PetUtility.IsPassiveSkill(petSkillCfg.skillId) then
    typeText = textRes.Pet.SkillType[2]
    consume = textRes.Skill[8]
  else
    typeText = textRes.Pet.SkillType[1]
    local costInfo = self:GetSkillCostInfo(skillCfg.conditionId, level, level)
    consume = self:GetFormatCostText(costInfo)
  end
  local pos = {
    sourceX = sourceX,
    sourceY = sourceY,
    sourceW = sourceW,
    sourceH = sourceH,
    prefer = prefer
  }
  local operations = self:GetOperations(context)
  require("GUI.CommonSkillTip").Instance():ShowSimplePanel(iconId, name, description, typeText, consume, isUnlock, unlockTip, pos, operations)
end
def.method("table", "boolean", "number", "number", "number", "number", "number").ShowPartnerSkillTip = function(self, partnerSkillCfg, isUnlock, sourceX, sourceY, sourceW, sourceH, prefer)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local skillCfg = partnerSkillCfg.skillCfg
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local level = -1
  local description = skillCfg.description
  local unlockTip = ""
  if isUnlock ~= true then
    if partnerSkillCfg.needPartnerXiuLianLevel > 0 and 0 < partnerSkillCfg.needPartnerXiuLianLevelCount then
      if unlockTip ~= "" then
        unlockTip = unlockTip .. "\n"
      end
      unlockTip = unlockTip .. string.format(textRes.Partner[52], partnerSkillCfg.needPartnerXiuLianLevel)
    else
      if partnerSkillCfg.needPartnerXiuLianLevel > 0 then
        if unlockTip ~= "" then
          unlockTip = unlockTip .. "\n"
        end
        unlockTip = unlockTip .. string.format(textRes.Partner[50], partnerSkillCfg.needPartnerXiuLianLevel)
      end
      if 0 < partnerSkillCfg.needPartnerXiuLianLevelCount then
        if unlockTip ~= "" then
          unlockTip = unlockTip .. "\n"
        end
        unlockTip = unlockTip .. string.format(textRes.Partner[51], partnerSkillCfg.needPartnerXiuLianLevelCount)
      end
    end
  end
  local typeText = ""
  local consume = ""
  if SkillUtility.IsEnchantingSkill(skillCfg.id) then
    typeText = textRes.Skill.SkillType[100]
    consume = string.format(textRes.Skill.SkillUseType[100], 0)
  elseif SkillUtility.IsPassiveSkill(skillCfg.id) then
    typeText = textRes.Pet.SkillType[2]
    consume = textRes.Skill[8]
  else
    local costInfo = self:GetSkillCostInfo(skillCfg.conditionId, heroProp.level, heroProp.level)
    consume = self:GetFormatCostText(costInfo)
    typeText = textRes.Skill.SkillType[skillCfg.type]
  end
  require("GUI.CommonSkillTip").Instance():ShowPanel(iconId, name, level, description, typeText, consume, isUnlock, unlockTip, sourceX, sourceY, sourceW, sourceH, prefer)
end
def.method("number", "number", "boolean", "number", "number", "number", "number", "number").ShowPetMarkSkillTip = function(self, skillId, skillLevel, isUnlock, sourceX, sourceY, sourceW, sourceH, prefer)
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  local iconId = skillCfg.iconId
  local name = skillCfg.name
  local level = -1
  local description = skillCfg.description
  local unlockTip = ""
  if isUnlock ~= true then
    unlockTip = string.format(textRes.Pet.PetMark[32], skillLevel)
  end
  local typeText, consume
  if SkillUtility.IsPassiveSkill(skillId) then
    typeText = textRes.Pet.SkillType[2]
    consume = textRes.Skill[8]
  else
    typeText = textRes.Pet.SkillType[1]
    local heroProp = require("Main.Hero.Interface").GetHeroProp()
    local costInfo = self:GetSkillCostInfo(skillCfg.conditionId, 1, heroProp.level)
    consume = self:GetFormatCostText(costInfo)
  end
  require("GUI.CommonSkillTip").Instance():ShowPanel(iconId, name, level, description, typeText, consume, isUnlock, unlockTip, sourceX, sourceY, sourceW, sourceH, prefer)
end
def.method("number", "number", "number", "=>", "table").GetSkillCostInfo = function(self, conditionId, skillLevel, roleLevel)
  if conditionId == SkillModule.NO_COST_CONDITION_ID then
    return {
      nocost = true,
      costList = {}
    }
  end
  local costInfo = {}
  costInfo.nocost = true
  costInfo.costList = {}
  costInfo.reqList = {}
  local conditionCfg = SkillUtility.GetSkillConditionCfg(conditionId)
  for i, cost in ipairs(conditionCfg) do
    if cost.formulaid ~= 0 then
      local costValue = self:CalcFormulaById(cost.formulaid, skillLevel, roleLevel)
      costInfo.costList[cost.costType] = costValue
      costInfo.nocost = false
    end
    if cost.reqType > ConditionType.NONE then
      local reqValue = self:CalcFormulaById(cost.reqFormulaId, skillLevel, roleLevel)
      costInfo.reqList[cost.reqType] = reqValue
    end
  end
  return costInfo
end
def.method("table", "=>", "string").GetFormatCostText = function(self, costInfo)
  if costInfo.nocost then
    return textRes.Skill[8]
  end
  local text = textRes.Skill[9]
  local count = 1
  for type, value in pairs(costInfo.costList) do
    local value = self:Adjust2ProperlyValue(type, value)
    if count == 1 then
      local typeCost = string.format(textRes.Skill.SkillUseType[type], value)
      text = string.format("%s%s", text, typeCost)
    else
      local separator = textRes.Common[19]
      local typeCost = string.format(textRes.Skill.SkillUseType[type], value)
      text = string.format("%s%s%s", text, separator, typeCost)
    end
    count = count + 1
  end
  return text
end
def.method("number", "number", "=>", "number").Adjust2ProperlyValue = function(self, type, value)
  if type == SkillUseType.HPRATE or type == SkillUseType.MPRATE or type == SkillUseType.ANGERRATE then
    return value / 100
  else
    return value
  end
end
def.method("number", "number", "number", "=>", "number").CalcFormulaById = function(self, formulaid, skillLevel, roleLevel)
  local formulaCfg = SkillUtility.GetSkillFormulaCfg(formulaid)
  if formulaCfg.className == "CommonSKillLVFormula" then
    return Formulation.Calc(formulaCfg.className, skillLevel, unpack(formulaCfg.params))
  elseif formulaCfg.className == "CommonFighterLVFormula" then
    return Formulation.Calc(formulaCfg.className, roleLevel, unpack(formulaCfg.params))
  else
    warn(string.format("Unknow formula: id = %d, name = %s", formulaid, formulaCfg.className))
    return 0
  end
end
return SkillTipMgr.Commit()
