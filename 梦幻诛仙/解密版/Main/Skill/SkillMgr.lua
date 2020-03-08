local Lplus = require("Lplus")
local SkillMgr = Lplus.Class("SkillMgr")
local SkillBagData = require("Main.Skill.data.SkillBagData")
local SkillData = require("Main.Skill.data.SkillData")
local SkillUtility = require("Main.Skill.SkillUtility")
local SkillModule = Lplus.ForwardDeclare("SkillModule")
local SkillType = require("consts.mzm.gsp.skill.confbean.SkillType")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local SkillSpecialType = require("consts.mzm.gsp.skill.confbean.SkillSpecialType")
local def = SkillMgr.define
def.const("string").ENCHANTING_SKILL_NOTIFY_KEY = "SKILL_ENCHANTING_NOTIFY"
def.field("table")._occupationSkillBagMap = nil
def.field("table")._occupationSkillBagList = nil
def.field("table")._tmpSkillMap = nil
def.field("table")._enchantingSKill = nil
def.field("table")._unlockedSkills = nil
local instance
def.static("=>", SkillMgr).Instance = function()
  if instance == nil then
    instance = SkillMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self._tmpSkillMap = {}
  self._unlockedSkills = {}
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_UNLOCK, SkillMgr.OnOccupationSkillUnlock)
end
def.method("table").FillOccupationSkillBag = function(self, skillBagList)
  self._occupationSkillBagMap = {}
  self._occupationSkillBagList = nil
  for i, skillBag in ipairs(skillBagList) do
    local skillBagData = SkillBagData()
    skillBagData:RawSet(skillBag)
    self._occupationSkillBagMap[skillBagData.id] = skillBagData
  end
end
def.method("table").UpdateOccupationSkillBag = function(self, skillBag)
  local skillBagId = skillBag.skillbagid
  local skillBagData = self._occupationSkillBagMap[skillBagId]
  if skillBagData then
    skillBagData:GetSkillList()
    skillBagData:RawSet(skillBag)
  else
    warn(string.format("Try to update occupation skill bag(id=%d), but it isn't exist.", skillBagId))
  end
end
def.method("=>", "table").GetOccupationSkillBagList = function(self)
  if self._occupationSkillBagMap == nil then
    return {}
  end
  if self._occupationSkillBagList == nil then
    local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
    local cfg = SkillUtility.GetSkillBagOccupationCfg(heroProp.occupation)
    self._occupationSkillBagList = {}
    for i, skillBagId in ipairs(cfg) do
      local skillBag = self._occupationSkillBagMap[skillBagId]
      table.insert(self._occupationSkillBagList, skillBag)
    end
  end
  return self._occupationSkillBagList
end
def.method("number", "=>", "table").GetOccupationSkillBag = function(self, skillBagId)
  if self._occupationSkillBagMap == nil then
    return nil
  end
  return self._occupationSkillBagMap[skillBagId]
end
def.method("=>", "table").GetInFightSkillList = function(self)
  local occupationSkillBagList = self:GetOccupationSkillBagList()
  local inFightSkillList = self:GetBasicSkillList()
  for i, skillBag in ipairs(occupationSkillBagList) do
    local skillList = skillBag:GetSkillList()
    for i, skillData in ipairs(skillList) do
      if self:FilterInFightSkill(skillData) then
        table.insert(inFightSkillList, skillData)
      end
    end
  end
  local tmpSkills = self:GetTmpSkills()
  for i, skillData in ipairs(tmpSkills) do
    table.insert(inFightSkillList, skillData)
  end
  local fabaoSpeSkills = self:GetFaBaoSpecialSkills()
  for i, skillData in ipairs(fabaoSpeSkills) do
    table.insert(inFightSkillList, skillData)
  end
  local marriageSkills = self:GetMarriageSkills()
  for i, skillData in ipairs(marriageSkills) do
    table.insert(inFightSkillList, skillData)
  end
  return inFightSkillList
end
def.method(SkillData, "=>", "boolean").FilterInFightSkill = function(self, skillData)
  local isLocked = not skillData:IsUnlock()
  if isLocked then
    return false
  end
  if skillData:IsPassiveSkill() then
    return false
  end
  if skillData:IsEnchantingSkill() then
    return false
  end
  if self._tmpSkillMap[skillData.id] then
    return false
  end
  return true
end
def.method("=>", "table").GetBasicSkillList = function(self)
  local basicSkillList = {}
  local skillIdList = {
    SkillModule.NORMAL_ATTACK_SKILL_ID,
    SkillModule.DEFENCE_SKILL_ID
  }
  for i, skillId in ipairs(skillIdList) do
    local skillData = SkillData()
    skillData.id = skillId
    skillData.level = 1
    skillData.unlockLevel = 1
    skillData.isBasicSkill = true
    table.insert(basicSkillList, skillData)
  end
  return basicSkillList
end
def.method("=>", "table").GetOnHookSkillList = function(self)
  local occupationSkillBagList = self:GetOccupationSkillBagList()
  local onHookSkillList = self:GetBasicSkillList()
  for i, skillBag in ipairs(occupationSkillBagList) do
    local skillList = skillBag:GetSkillList()
    for i, skillData in ipairs(skillList) do
      if self:FilterOnHookSkill(skillData) then
        table.insert(onHookSkillList, skillData)
      end
    end
  end
  return onHookSkillList
end
def.method(SkillData, "=>", "boolean").FilterOnHookSkill = function(self, skillData)
  local isLocked = not skillData:IsUnlock()
  if isLocked then
    return false
  end
  if skillData:IsPassiveSkill() then
    return false
  end
  if skillData:IsEnchantingSkill() then
    return false
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillData.id)
  if skillCfg == nil or not skillCfg.canAuto then
    return false
  end
  return true
end
def.method("=>", SkillData).GetEnchantingSkill = function(self)
  if self._enchantingSKill then
    return self._enchantingSKill
  end
  local skillBagList = self:GetOccupationSkillBagList()
  for i = #skillBagList, 1, -1 do
    local skillBag = skillBagList[i]
    local skillList = skillBag:GetSkillList()
    for i, skillData in ipairs(skillList) do
      if skillData:IsEnchantingSkill() then
        self._enchantingSKill = skillData
        return skillData
      end
    end
  end
  return nil
end
def.method("=>", "table").GetFaBaoSpecialSkills = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local fabaoSkills = ItemModule.Instance():GetExtraSkill()
  local skillList = {}
  for i, skillId in ipairs(fabaoSkills) do
    if SkillUtility.IsActiveSkill(skillId) then
      local skillCfg = SkillUtility.GetSkillCfg(skillId)
      if skillCfg.type == SkillType.SPECIAL then
        local skillData = SkillData()
        skillData.id = skillId
        skillData.level = 1
        skillData.unlockLevel = 1
        skillData.isFaBaoSkill = true
        table.insert(skillList, skillData)
      end
    end
  end
  return skillList
end
def.method("=>", "table").GetTmpSkills = function(self)
  local skillList = {}
  for skillId, skillLevel in pairs(self._tmpSkillMap) do
    local skillData = SkillData()
    skillData.id = skillId
    skillData.level = skillLevel
    skillData.unlockLevel = 0
    table.insert(skillList, skillData)
  end
  return skillList
end
def.method("=>", "table").GetMarriageSkills = function(self)
  local MarriageInterface = require("Main.Marriage.MarriageInterface")
  local skills = MarriageInterface.GetMarriageSkills()
  local skillList = {}
  if skills then
    for i, skill in ipairs(skills) do
      local skillData = SkillData()
      skillData.id = skill.skillId
      skillData.level = skill.level
      skillData.unlockLevel = 0
      table.insert(skillList, skillData)
    end
  end
  return skillList
end
def.method("=>", "boolean").HasNotify = function(self)
  if self:HasEnchantingSkillNotify() then
    return true
  end
  if require("Main.Oracle.OracleModule").Instance():NeedReddot() then
    return true
  end
  local skillFuncTypes = {
    SkillModule.SkillFuncType.Occupation,
    SkillModule.SkillFuncType.Exercise,
    SkillModule.SkillFuncType.Living,
    SkillModule.SkillFuncType.Gang
  }
  for i, skillFuncType in ipairs(skillFuncTypes) do
    if SkillModule.Instance():IsSkillFuncJustUnlock(skillFuncType) then
      return true
    end
  end
  return false
end
def.method().CheckNotify = function(self)
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.SKILL_NOTIFY_UPDATE, {})
end
local enchantingSkillNotifyLevel
def.method("=>", "boolean").HasEnchantingSkillNotify = function(self)
  local enchantingSKill = self:GetEnchantingSkill()
  if enchantingSKill == nil then
    return false
  end
  if enchantingSkillNotifyLevel == nil then
    enchantingSkillNotifyLevel = SkillUtility.GetSkillConsts("FUMO_SKILL_GUIDE")
  end
  if enchantingSKill.level < enchantingSkillNotifyLevel then
    return false
  end
  if not LuaPlayerPrefs.HasRoleKey(SkillMgr.ENCHANTING_SKILL_NOTIFY_KEY) then
    return false
  end
  return true
end
def.method("boolean").SetEnchantingSkillNotify = function(self, state)
  if state then
    LuaPlayerPrefs.SetRoleNumber(SkillMgr.ENCHANTING_SKILL_NOTIFY_KEY, 1)
  else
    LuaPlayerPrefs.DeleteRoleKey(SkillMgr.ENCHANTING_SKILL_NOTIFY_KEY)
  end
  self:CheckNotify()
end
def.method("table", "=>", "boolean").IsOccupationSkillBagMaxLevel = function(self, skillBag)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  if skillBag.level < heroProp.level then
    return false
  else
    return true
  end
end
def.method("=>", "boolean").IsAllOccupationSkillBagMaxLevel = function(self)
  if self._occupationSkillBagMap == nil then
    return true
  end
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  for k, skillBag in pairs(self._occupationSkillBagMap) do
    if skillBag.level < heroProp.level then
      return false
    end
  end
  return true
end
def.method("number", "number", "=>", "table").GetPassiveSkillEffects = function(self, skillId, skillLevel)
  local passiveSkillCfg = SkillUtility.GetPassiveSkillCfg(skillId)
  local groupEffects = {}
  for i, effectGroupId in ipairs(passiveSkillCfg.effectIdList) do
    local groupEffect = self:GetEffectGroupEffect(effectGroupId, skillLevel)
    table.insert(groupEffects, groupEffect)
  end
  return groupEffects
end
def.method("number", "number", "=>", "table").GetEffectGroupEffect = function(self, effectGroupId, skillLevel)
  local effectGroup = SkillUtility.GetOutFightEffectGroup(effectGroupId)
  local roleEffectCfg = SkillUtility.GetRoleEffectCfg(effectGroup.effectId)
  if nil == roleEffectCfg then
    warn(string.format("[ERROR][SkillMgr:GetEffectGroupEffect] roleEffectCfg nil for effectId[%d] of effectGroup[%d].", effectGroup.effectId, effectGroupId))
    return nil
  end
  local prop = 0
  if roleEffectCfg.baseProp ~= 0 then
    prop = roleEffectCfg.baseProp
  elseif roleEffectCfg.fightProp ~= 0 then
    prop = roleEffectCfg.fightProp
  end
  local classname = roleEffectCfg.classname
  local effectGroupParams = {}
  for i, formulaId in ipairs(effectGroup.formulaIdList) do
    local result = self:GetFormulaResult(formulaId, skillLevel)
    table.insert(effectGroupParams, result)
  end
  local effectResult = SkillUtility.EffectFormula(roleEffectCfg.classname, effectGroupParams)
  local groupEffect = {
    prop = prop,
    value = effectResult,
    fenmu = roleEffectCfg.fenmu,
    classname = classname
  }
  return groupEffect
end
def.method("number", "number", "=>", "number").GetFormulaResult = function(self, formulaId, skillLevel)
  local formulaCfg = SkillUtility.GetOutFightEffectFormulaCfg(formulaId)
  if formulaCfg == nil then
    return 0
  end
  local Formulation = require("Main.Common.Formulation")
  local result = Formulation.Calc(formulaCfg.className, skillLevel, unpack(formulaCfg.params))
  return result
end
def.method("=>", "number").GetSkillBagMaxLevel = function(self)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local skillBagMaxLevel = heroProp.level
  return skillBagMaxLevel
end
def.method("=>", "userdata").GetLevelAllSkillBagMaxNeed = function(self)
  local skillBagList = self:GetOccupationSkillBagList()
  local needSilver = Int64.new(0)
  for i, skillBag in ipairs(skillBagList) do
    needSilver = needSilver + self:GetLevelSkillBagMaxNeed(skillBag.id)
  end
  return needSilver
end
def.method("number", "=>", "userdata").GetLevelSkillBagMaxNeed = function(self, skillBagId)
  local skillBag = self:GetOccupationSkillBag(skillBagId)
  local skillBagCfg = skillBag:GetCfgData()
  local skillBagMaxLevel = self:GetSkillBagMaxLevel()
  local needSilver = Int64.new(0)
  for level = skillBag.level, skillBagMaxLevel - 1 do
    local levelUpNeedCfg = SkillUtility.GetOccupationSkillBagLevelUpNeedCfg(level, skillBagCfg.levelUpCfgId)
    needSilver = needSilver + Int64.new(levelUpNeedCfg.needSilver)
  end
  return needSilver
end
def.method("=>", "boolean").HaveSilverToLevelUpSkillBag = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  local skillBagList = self:GetOccupationSkillBagList()
  for i, skillBag in ipairs(skillBagList) do
    if not self:IsOccupationSkillBagMaxLevel(skillBag) then
      local skillBagCfg = skillBag:GetCfgData()
      local levelUpNeedCfg = SkillUtility.GetOccupationSkillBagLevelUpNeedCfg(skillBag.level, skillBagCfg.levelUpCfgId)
      local needSilver = Int64.new(levelUpNeedCfg.needSilver)
      if moneySilver >= needSilver then
        return true
      end
    end
  end
  return false
end
def.method("=>", "table").GetAutoLevelUpSkillBagConsume = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  local skillBagList = self:GetOccupationSkillBagList()
  local skillBagMaxLevel = self:GetSkillBagMaxLevel()
  local consumeSilver = Int64.new(0)
  local stop = false
  local mainSkillBagIndex = 1
  local levelUpBound = skillBagMaxLevel - 1
  for i, skillBag in ipairs(skillBagList) do
    local skillBagCfg = skillBag:GetCfgData()
    for level = skillBag.level, levelUpBound do
      local levelUpNeedCfg = SkillUtility.GetOccupationSkillBagLevelUpNeedCfg(level, skillBagCfg.levelUpCfgId)
      local needSilver = Int64.new(levelUpNeedCfg.needSilver)
      if moneySilver >= needSilver + consumeSilver then
        consumeSilver = consumeSilver + needSilver
      end
      if moneySilver <= consumeSilver then
        stop = true
        break
      end
      if i == mainSkillBagIndex then
        levelUpBound = level
      end
    end
    if stop then
      break
    end
  end
  return {silver = consumeSilver}
end
def.method("table").SyncAddTempSkillList = function(self, skillMap)
  self._tmpSkillMap = {}
  for skillId, skillLevel in pairs(skillMap) do
    self._tmpSkillMap[skillId] = skillLevel
  end
end
def.method("table").SyncRemoveTempSkillList = function(self, skillIdList)
  for i, skillId in ipairs(skillIdList) do
    self._tmpSkillMap[skillId] = nil
  end
end
def.method("number", "number", "boolean").MarkUnlockState = function(self, skillBagId, skillId, state)
  self._unlockedSkills[skillBagId] = self._unlockedSkills[skillBagId] or {}
  self._unlockedSkills[skillBagId][skillId] = state and true or nil
end
def.method("number", "=>", "boolean").HasJustUnlockedSkill = function(self, skillBagId)
  if self._unlockedSkills[skillBagId] == nil then
    return false
  end
  return table.nums(self._unlockedSkills[skillBagId]) > 0
end
def.method("number", "number", "=>", "boolean").IsJustUnlockedSkill = function(self, skillBagId, skillId)
  if self._unlockedSkills[skillBagId] == nil then
    return false
  end
  return self._unlockedSkills[skillBagId][skillId] and true or false
end
def.method().Reset = function(self)
  self._tmpSkillMap = {}
  self._enchantingSKill = nil
  if _G.leaveWorldReason ~= _G.LeaveWorldReason.RECONNECT then
    self._unlockedSkills = {}
  end
end
def.static("table", "table").OnOccupationSkillUnlock = function(params, context)
  local skillBagId, skillId = unpack(params)
  instance:MarkUnlockState(skillBagId, skillId, true)
end
def.method("number").LevelUpOccupationSkillBag = function(self, skillBagId)
  self:C2S_LevelUpOccupationSkillBag(skillBagId)
end
def.method().AutoLevelUpOccupationSkillBag = function(self)
  self:C2S_AutoLevelUpOccupationSkillBag()
end
def.method("userdata", "=>", "boolean").IsNeedAutoLevelConfirm = function(self, consumeSilver)
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  local scaler = 10000
  local THRESHOLD = SkillUtility.GetSkillConsts("TIPS_RATE")
  return consumeSilver > moneySilver * THRESHOLD / scaler
end
def.method("number").C2S_LevelUpOccupationSkillBag = function(self, skillBagId)
  local p = require("netio.protocol.mzm.gsp.skill.CMenPaiLevelUpReq").new(skillBagId)
  gmodule.network.sendProtocol(p)
  print(string.format("Send protocol (%s)[%d]", "netio.protocol.mzm.gsp.skill.CMenPaiLevelUpReq", skillBagId))
end
def.method().C2S_AutoLevelUpOccupationSkillBag = function(self)
  local p = require("netio.protocol.mzm.gsp.skill.CMenPaiLevelUpAutoReq").new()
  gmodule.network.sendProtocol(p)
  print(string.format("Send protocol (%s)[]", "netio.protocol.mzm.gsp.skill.CMenPaiLevelUpAutoReq"))
end
return SkillMgr.Commit()
