local Lplus = require("Lplus")
local ExerciseSkillMgr = Lplus.Class("ExerciseSkillMgr")
local def = ExerciseSkillMgr.define
local ExerciseSkillBagData = require("Main.Skill.data.ExerciseSkillBagData")
local SkillData = require("Main.Skill.data.SkillData")
local SkillUtility = require("Main.Skill.SkillUtility")
local SkillModule = Lplus.ForwardDeclare("SkillModule")
local ItemModule = Lplus.ForwardDeclare("ItemModule")
local ItemUtils = Lplus.ForwardDeclare("ItemUtils")
local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
local CResult = {
  Success = 0,
  ReachMaxLevel = 1,
  SilverNotEnough = 2,
  DefaultSkillNotExist = 3
}
def.const("table").CResult = CResult
def.const("number").TIP_ID = 701600000
def.field("table")._skillBagList = nil
def.field("table")._skillBagMap = nil
def.field("number")._defaultSkillBagId = 0
def.field("table")._curMaxSkillLevelCfg = nil
def.field("boolean")._roleLevelChanged = true
local instance
def.static("=>", ExerciseSkillMgr).Instance = function()
  if instance == nil then
    instance = ExerciseSkillMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  self._skillBagList = {}
  self._skillBagMap = {}
  self._curMaxSkillLevelCfg = {}
end
def.method("table").FillSkillBags = function(self, data)
  self._skillBagList = {}
  self._skillBagMap = {}
  self._defaultSkillBagId = data.defaultSkill
  for i, v in pairs(data.skillBagList) do
    local skillBagData = ExerciseSkillBagData()
    skillBagData:RawSet(v)
    if skillBagData.id == self._defaultSkillBagId then
      skillBagData.isDefault = true
    end
    table.insert(self._skillBagList, skillBagData)
    self._skillBagMap[skillBagData.id] = skillBagData
  end
  table.sort(self._skillBagList, function(left, right)
    if left.id < right.id then
      return true
    else
      return false
    end
  end)
end
def.method("=>", "table").GetSkillBagList = function(self)
  return self._skillBagList
end
def.method("number", "=>", ExerciseSkillBagData).GetSkillBag = function(self, skillBagId)
  return self._skillBagMap[skillBagId]
end
def.method("=>", "number").GetDefaultSkillBagId = function(self)
  return self._defaultSkillBagId
end
def.method("=>", "boolean").IsAllSkillBagLevelMax = function(self)
  for i, skillBagData in ipairs(self._skillBagList) do
    if not self:IsSkillBagMaxLevel(skillBagData.id) then
      return false
    end
  end
  return true
end
def.method("number", "=>", "boolean").IsSkillBagMaxLevel = function(self, skillBagId)
  local skillBag = self:GetSkillBag(skillBagId)
  if skillBag == nil then
    return true
  end
  return skillBag.level >= skillBag:GetMaxLevel()
end
def.method("number", "=>", "number").GetCurSkillBagMaxLevel = function(self, cfgId)
  if self._roleLevelChanged then
    local roleLevel = require("Main.Hero.Interface").GetHeroProp().level
    self._curMaxSkillLevelCfg = SkillUtility.GetExerciseSkillCurMaxLevelCfg(roleLevel)
    self._roleLevelChanged = false
  end
  return self._curMaxSkillLevelCfg[cfgId]
end
def.method("=>", "boolean").HasXiuLianExpItem = function(self)
  local ItemModule = require("Main.Item.ItemModule")
  return ItemModule.Instance():GetNumByItemType(ItemModule.BAG, ItemType.XIULIAN_EXP_ITEM) > 0
end
def.method().MarkRoleLevelChanged = function(self)
  self._roleLevelChanged = true
end
def.method("table").RawUpdateSkillBagInfo = function(self, data)
  local skillBag = data.skillBag
  local skillBagData = self:GetSkillBag(skillBag.skillBagId)
  if skillBagData then
    self:CheckSkillBagLevelUpEvent(skillBag.skillBagId, skillBagData.level, skillBag.skillLevel)
    skillBagData:RawSet(skillBag)
    Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.EXERCISE_SKILL_UPDATE, {
      skillBagData.id
    })
  else
    warn("Attemp to update exercise skill bag(" .. skillBag.skillBagId .. "), but it isn't exist.")
  end
end
def.method("number", "number", "number").CheckSkillBagLevelUpEvent = function(self, skillBagId, lastlevel, curlevel)
  if lastlevel < curlevel then
    Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.EXERCISE_SKILL_LEVEL_UP, {
      skillBagId,
      lastlevel,
      curlevel
    })
  end
end
def.method("number").SyncDefaultSkillBag = function(self, skillBagId)
  local skillBagData = self:GetSkillBag(self._defaultSkillBagId)
  skillBagData.isDefault = false
  local skillBagData = self:GetSkillBag(skillBagId)
  skillBagData.isDefault = true
  self._defaultSkillBagId = skillBagId
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.EXERCISE_SKILL_UPDATE, {
    skillBagData.id
  })
end
def.method("=>", "number").GetPerLevelNeedSilver = function(self)
  local value = SkillUtility.GetExerciseSkillConsts("XIULIAN_LEARN_NEED_SILVER")
  return value
end
def.method("=>", "number").GetSkillBagMaxLevel = function(self)
  local value = SkillUtility.GetExerciseSkillConsts("SKILL_BAG_MAX_LEVEL")
  return value
end
def.method("=>", "number").GetUnlockLevel = function(self)
  local value = SkillUtility.GetExerciseSkillConsts("OPEN_LEVEL")
  return value
end
def.method("=>", "number").GetHundredOpenLevel = function(self)
  local value = SkillUtility.GetExerciseSkillConsts("STUDY_HUNDRED_OPEN_LEVEL")
  return value
end
def.method("number", "number", "=>", "number").StudySkillBag = function(self, skillBagId, studyCount)
  local skillBag = self:GetSkillBag(skillBagId)
  if skillBag.level >= 30 then
    return CResult.ReachMaxLevel
  elseif not self:CanStudy(studyCount) then
    return CResult.SilverNotEnough
  else
    self:C2S_StudySkillBagReq(skillBagId, studyCount)
    return CResult.Success
  end
end
def.method("number", "=>", "boolean").CanStudy = function(self, studyCount)
  local useSilver = self:GetPerLevelNeedSilver()
  local haveSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  if Int64.lt(haveSilver, useSilver) then
    return false
  else
    return true
  end
end
def.method("number").SetAsDefaultSkillBag = function(self, skillBagId)
  self:C2S_SetDefaultSkillReq(skillBagId)
end
def.method("number", "number", "boolean", "=>", "number").UseXiuLianItemReq = function(self, skillBagId, itemKey, isAllUse)
  local skillBag = self:GetSkillBag(skillBagId)
  if skillBag == nil then
    return CResult.DefaultSkillNotExist
  elseif skillBag.level >= 30 then
    return CResult.ReachMaxLevel
  else
    self:C2S_UseXiuLianItemReq(skillBagId, itemKey, isAllUse)
    return CResult.Success
  end
end
def.method("=>", "number").GetNeededXiuLianExpItemKey = function(self)
  local items = ItemModule.Instance():GetOrderedItemsByBagId(ItemModule.BAG)
  for key, item in pairs(items) do
    local itemBase = ItemUtils.GetItemBase(item.id)
    if itemBase.itemType == ItemType.XIULIAN_EXP_ITEM then
      return item.itemKey
    end
  end
  return -1
end
def.static("table", "table", "=>", "boolean").XiuLianExpItemFilter = function(item, params)
  local itemBase = ItemUtils.GetItemBase(item.id)
  return itemBase.itemType == ItemType.XIULIAN_EXP_ITEM
end
def.method("number", "number").C2S_StudySkillBagReq = function(self, skillBagId, studyCount)
  warn("[ExerciseSkillMgr:C2S_StudySkillBagReq] send CStudySkillReq:", skillBagId, studyCount)
  local p = require("netio.protocol.mzm.gsp.xiulian.CStudySkillReq").new(skillBagId, studyCount)
  gmodule.network.sendProtocol(p)
end
def.method("number").C2S_SetDefaultSkillReq = function(self, skillBagId)
  local p = require("netio.protocol.mzm.gsp.xiulian.CSetDefaultSkillReq").new(skillBagId)
  gmodule.network.sendProtocol(p)
end
def.method("number", "number", "boolean").C2S_UseXiuLianItemReq = function(self, skillBagId, itemKey, isAllUse)
  local intIsAllUse = isAllUse and 1 or 0
  local p = require("netio.protocol.mzm.gsp.xiulian.CUseXiuLianItemReq").new(itemKey, skillBagId, intIsAllUse)
  gmodule.network.sendProtocol(p)
end
return ExerciseSkillMgr.Commit()
