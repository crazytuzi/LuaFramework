local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local SkillModule = Lplus.Extend(ModuleBase, "SkillModule")
local def = SkillModule.define
local LivingSkillData = require("Main.Skill.data.LivingSkillData")
local MakeEnchantingSkill = require("Main.Skill.ui.MakeEnchantingSkill")
local LivingSkillNode = require("Main.Skill.ui.LivingSkillNode")
local LivingSkillUtility = require("Main.Skill.LivingSkillUtility")
local SkillUtility = require("Main.Skill.SkillUtility")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local GangSkillData = require("Main.Skill.data.GangSkillData")
local GangSkillNode = require("Main.Skill.ui.GangSkillNode")
def.const("number").NO_COST_CONDITION_ID = 110100000
def.const("number").ACTIVE_SKILL_ID_PREFIX = 1100
def.const("number").PASSIVE_SKILL_ID_PREFIX = 1106
def.const("number").ENCHANTING_SKILL_ID_PREFIX = 1116
SkillModule.NORMAL_ATTACK_SKILL_ID = 0
SkillModule.DEFENCE_SKILL_ID = 0
def.const("table").SkillFuncType = {
  Occupation = 1,
  Exercise = 2,
  Living = 3,
  Gang = 4
}
local instance
def.static("=>", SkillModule).Instance = function()
  if instance == nil then
    instance = SkillModule()
    instance.m_moduleId = ModuleId.SKILL
  end
  return instance
end
def.override().Init = function(self)
  require("Main.Skill.SkillUIMgr").Instance():Init()
  SkillModule.NORMAL_ATTACK_SKILL_ID = constant.FightConst.ATTACK_SKILL
  SkillModule.DEFENCE_SKILL_ID = constant.FightConst.DEFENCE_SKILL
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:Reset()
  end)
  Event.RegisterEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_SKILL_CLICK, SkillModule.OnSkillPanelIconClick)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, SkillModule.OnInitHeroProp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, SkillModule.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_ACCESS, SkillModule.OnLivingSkillAccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skill.SSyncMenPaiSkillBagInfo", SkillModule.OnSSyncMenPaiSkillBagInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skill.SMenPaiLevelUpRes", SkillModule.OnSMenPaiLevelUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skill.SSyncSkillCommonTip", SkillModule.OnSSyncSkillCommonTip)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skill.SMenPaiSkillAutoLevelUpRes", SkillModule.OnSMenPaiSkillAutoLevelUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skill.SSyncTempSkillListAdd", SkillModule.OnSSyncTempSkillListAdd)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skill.SSyncTempSkillListRemove", SkillModule.OnSSyncTempSkillListRemove)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskill.SSyncLifeSkillBagInfo", SkillModule.OnSSyncLifeSkillBagInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskill.SSyncCommonInfo", SkillModule.OnSSyncCommonInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskill.SLifeSkillLevelUpRes", SkillModule.OnLifeSkillLevelUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskill.SLifeSkillLevelResetSuccess", SkillModule.OnSLifeSkillLevelResetSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskill.SLifeSkillLevelResetFailed", SkillModule.OnSLifeSkillLevelResetFailed)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskill.SCookRes", SkillModule.OnSCookRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskill.SLianYaoRes", SkillModule.OnSLianYaoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.lifeskill.SMakeWuQIFuRes", SkillModule.OnSMakeWuQIFuRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skill.SFuMoSkillPreviewRes", SkillModule.OnSFuMoSkillPreviewRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.skill.SUseFuMoSkillRes", SkillModule.OnSUseFuMoSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResUseFumoItem", SkillModule.OnSResUseFumoItem)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.item.SResEquipFumoInfo", SkillModule.OnSResEquipFumoInfo)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.SELECT_ENCHANTING_SKILL, SkillModule.OnEnChantingSkillClick)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_PANEL_USE_ENCHANTING_SKILL, SkillModule.OnRequireToEnchantingSkill)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_ENERGY_PANEL_USE_LIVING_SKILL, SkillModule.OnRequireToUseLivingSkill)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiulian.SSyncXiuLainSkillBagInfo", SkillModule.OnSSyncXiuLainSkillBagInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiulian.SSyncCommonInfo", SkillModule.OnSSyncXiuLainCommonInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiulian.SSyncSkillExpChange", SkillModule.OnSSyncSkillExpChange)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiulian.SSyncSkillInfo", SkillModule.OnSSyncSkillInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.xiulian.SSetDefaultSKillRes", SkillModule.OnSSetDefaultSKillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangskill.SSyncGangSkillBagInfo", SkillModule.OnSSyncGangSkillBagInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangskill.SGangSkillLevelUpRes", SkillModule.OnSGangSkillLevelUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.gangskill.SGangSkillError", SkillModule.OnSGangSkillError)
  ModuleBase.Init(self)
end
def.override().OnReset = function(self)
  LivingSkillData.Instance():SetAllNull()
  GangSkillData.Instance():SetAllNull()
end
def.method("number", "=>", "number").GetSkillFuncUnlockLevel = function(self, type)
  local unlockLevel
  if type == SkillModule.SkillFuncType.Occupation then
    unlockLevel = SkillUtility.GetSkillConsts("OPENLEVEL")
  elseif type == SkillModule.SkillFuncType.Exercise then
    unlockLevel = require("Main.Skill.ExerciseSkillMgr").Instance():GetUnlockLevel()
  elseif type == SkillModule.SkillFuncType.Living then
    unlockLevel = LivingSkillUtility.GetLivingSkillConst("OPEN_LEVEL")
  elseif type == SkillModule.SkillFuncType.Gang then
    unlockLevel = SkillUtility.GetGangSkillConst("ENABLE_GANG_SKILL_ROLE_LEVEL")
  else
    unlockLevel = 999
  end
  return unlockLevel
end
def.method("number", "=>", "boolean").IsSkillFuncUnlock = function(self, type)
  local heroProp = require("Main.Hero.Interface").GetBasicHeroProp()
  local heroLevel = heroProp.level
  local unlockLevel = self:GetSkillFuncUnlockLevel(type)
  return heroLevel >= unlockLevel
end
def.method("number", "=>", "boolean").CanEnhanceSkillFunc = function(self, type)
  local isLocked = not self:IsSkillFuncUnlock(type)
  if isLocked then
    return false
  end
  local canEnhance = false
  if type == SkillModule.SkillFuncType.Occupation then
    canEnhance = not require("Main.Skill.SkillMgr").Instance():IsAllOccupationSkillBagMaxLevel()
  elseif type == SkillModule.SkillFuncType.Exercise then
    canEnhance = not require("Main.Skill.ExerciseSkillMgr").Instance():IsAllSkillBagLevelMax()
  end
  return canEnhance
end
def.method("=>", "table").GetDefaultExerciseSkill = function(self)
  local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
  local skillBagId = ExerciseSkillMgr.Instance():GetDefaultSkillBagId()
  local skillBag = ExerciseSkillMgr.Instance():GetSkillBag(skillBagId)
  return skillBag
end
def.method("number", "number").CheckNewSkillFunc = function(self, lastLevel, curLevel)
  local function checkOpen(skillFuncType)
    local level = self:GetSkillFuncUnlockLevel(skillFuncType)
    if level > lastLevel and level <= curLevel then
      self:MarkNewSkillFuncOpen(skillFuncType, true)
      return 1
    end
    return 0
  end
  local ret = 0
  ret = ret + checkOpen(SkillModule.SkillFuncType.Occupation)
  ret = ret + checkOpen(SkillModule.SkillFuncType.Exercise)
  ret = ret + checkOpen(SkillModule.SkillFuncType.Living)
  ret = ret + checkOpen(SkillModule.SkillFuncType.Gang)
  if ret > 0 then
    require("Main.Skill.SkillMgr").Instance():CheckNotify()
  end
end
local keyBase = "SKILL_NEW_SKILL_FUNC_OPEN"
def.method("number", "boolean").MarkNewSkillFuncOpen = function(self, skillFuncType, state)
  local key = string.format("%s_%d", keyBase, skillFuncType)
  local val = state and 1 or 0
  LuaPlayerPrefs.SetRoleInt(key, val)
end
def.method("number", "=>", "boolean").IsSkillFuncJustUnlock = function(self, skillFuncType)
  if not self:IsSkillFuncUnlock(skillFuncType) then
    return false
  end
  local key = string.format("%s_%d", keyBase, skillFuncType)
  if not LuaPlayerPrefs.HasRoleKey(key) then
    return false
  end
  local val = LuaPlayerPrefs.GetRoleInt(key)
  return val == 1 and true or false
end
def.static("table", "table").OnInitHeroProp = function(p1, p2)
  local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
  ExerciseSkillMgr.Instance():MarkRoleLevelChanged()
end
def.static("table", "table").OnHeroLevelUp = function(p1, p2)
  local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
  ExerciseSkillMgr.Instance():MarkRoleLevelChanged()
  instance:CheckNewSkillFunc(p1.lastLevel, p1.level)
end
def.static("table", "table").OnRequireToEnchantingSkill = function(p1, p2)
  MakeEnchantingSkill.RequireToUseSkill(p1[2], p1[1])
end
def.static("table", "table").OnRequireToUseLivingSkill = function(p1, p2)
  LivingSkillNode.RequireToUseLivingSkill(p1[1], p1[2])
end
def.static("table", "table").OnLivingSkillAccess = function(p1, p2)
  local unlockLevel = SkillUtility.GetSkillConsts("OPENLEVEL")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if unlockLevel > heroProp.level then
    Toast(string.format(textRes.Skill[7], unlockLevel))
    return
  end
  require("Main.Skill.ui.SkillPanel").Instance():ShowPanel(3)
  require("Main.Skill.ui.SkillPanel").Instance():SetSelectSkillBagId(p1[1])
end
def.static("table").OnSResEquipFumoInfo = function(p)
  for k, v in pairs(p.fumoInoList) do
    MakeEnchantingSkill.SucceedUseEnchant(v.itemid, v.propertyType, v.addValue)
  end
end
def.static("table").OnSResUseFumoItem = function(p)
  MakeEnchantingSkill.SucceedUseEnchant(p.equipfumoinfo.itemid, p.equipfumoinfo.propertyType, p.equipfumoinfo.addValue)
end
def.static("table").OnSUseFuMoSkillRes = function(p)
  MakeEnchantingSkill.SucceedMakeEnChat(p.itemId)
end
def.static("table").OnSFuMoSkillPreviewRes = function(p)
  if MakeEnchantingSkill.Instance().bWaitToShowPanel then
    MakeEnchantingSkill.ShowEnChantingSkillPanel(p.skillId, p.needVigor, p.itemId)
  end
end
def.static("table", "table").OnEnChantingSkillClick = function(p1, p2)
  local SkillMgr = require("Main.Skill.SkillMgr")
  local skillData = SkillMgr.Instance():GetEnchantingSkill()
  if not skillData:IsUnlock() then
    Toast(textRes.Skill[26])
    return
  end
  MakeEnchantingSkill.ShowEnChantingSkill()
end
def.static("table").OnSSyncLifeSkillBagInfo = function(p)
  LivingSkillData.Instance():SetSkillBagsLevel(p.skillBagList)
end
def.static("table").OnSSyncCommonInfo = function(p)
  local res = p.res
  Toast(textRes.Skill.LivingSkillMakeRes[res])
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_COMMON_INFO, {
    p.res
  })
end
def.static("table").OnLifeSkillLevelUpRes = function(p)
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_BAG_LEVEL_UP_SUCCESS, {
    p.skillBagId,
    p.level
  })
end
def.static("table").OnSLifeSkillLevelResetSuccess = function(p)
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_BAG_LEVEL_RESET_SUCCESS, {
    p.skill_bag_id,
    p.after_level,
    p.return_silver,
    p.return_banggong
  })
end
def.static("table").OnSLifeSkillLevelResetFailed = function(p)
  if textRes.Skill.SLifeSkillLevelResetFailed[p.ret_code] then
    Toast(textRes.Skill.SLifeSkillLevelResetFailed[p.ret_code])
  else
    Toast(string.format(textRes.Skill.SLifeSkillLevelResetFailed[0], p.ret_code))
  end
end
def.static("table").OnSCookRes = function(p)
  local itemId = p.itemId
  local nums = p.itemNum or 1
  if nums == 2 then
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    local itemName = HtmlHelper.GetColoredItemName(itemId)
    local text = string.format(textRes.Skill[76], itemName)
    Toast(text)
  else
    LivingSkillUtility.ToastGetItemWithNums(itemId, nums)
  end
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_COOK_RES, {
    p.costVigor,
    p.itemId
  })
end
def.static("table").OnSMakeWuQIFuRes = function(p)
  local itemId = p.itemId
  LivingSkillUtility.ToastGetItem(itemId)
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_WEAPON_RES, {
    p.costVigor,
    p.itemId
  })
end
def.static("table").OnSLianYaoRes = function(p)
  local itemId = p.itemId
  local nums = p.itemNum or 1
  if nums == 2 then
    local HtmlHelper = require("Main.Chat.HtmlHelper")
    local itemName = HtmlHelper.GetColoredItemName(itemId)
    local text = string.format(textRes.Skill[77], itemName)
    Toast(text)
  else
    LivingSkillUtility.ToastGetItemWithNums(itemId, nums)
  end
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.LIVING_SKILL_DRUG_RES, {
    p.costVigor,
    p.itemId,
    p.itemKey
  })
end
def.static("table", "table").OnSkillPanelIconClick = function()
  local unlockLevel = SkillUtility.GetSkillConsts("OPENLEVEL")
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if unlockLevel > heroProp.level then
    Toast(string.format(textRes.Skill[7], unlockLevel))
    return
  end
  require("Main.Skill.ui.SkillPanel").Instance():ShowPanel(1)
end
def.static("table").OnSSyncMenPaiSkillBagInfo = function(data)
  print("OnSSyncMenPaiSkillBagInfo")
  local SkillMgr = require("Main.Skill.SkillMgr")
  SkillMgr.Instance():FillOccupationSkillBag(data.skillBags)
end
def.static("table").OnSMenPaiLevelUpRes = function(data)
  print("OnSMenPaiLevelUpRes")
  local SkillMgr = require("Main.Skill.SkillMgr")
  local skillBag = SkillMgr.Instance():GetOccupationSkillBag(data.skillBagInfo.skillbagid)
  local lastLevel = skillBag and skillBag.level or 0
  SkillMgr.Instance():UpdateOccupationSkillBag(data.skillBagInfo)
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_BAG_LEVEL_UP_SUCCESS, {
    data.skillBagInfo.skillbagid,
    data.useSilver,
    lastLevel
  })
end
def.static("table").OnSMenPaiSkillAutoLevelUpRes = function(data)
  print("OnSMenPaiLevelUpRes")
  local ItemModule = Lplus.ForwardDeclare("ItemModule")
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  if data.useSilver > 0 then
    PersonalHelper.UseMoneyMsg(ItemModule.MONEY_TYPE_SILVER, tostring(data.useSilver))
  end
  local SkillMgr = require("Main.Skill.SkillMgr")
  for skillBagId, level in pairs(data.skillMap) do
    local skillBag = SkillMgr.Instance():GetOccupationSkillBag(skillBagId)
    local lastLevel = skillBag and skillBag.level or 0
    SkillMgr.Instance():UpdateOccupationSkillBag({skillbagid = skillBagId, level = level})
    Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_BAG_LEVEL_UP_SUCCESS, {
      skillBagId,
      -1,
      lastLevel
    })
  end
end
def.static("table").OnSSyncTempSkillListAdd = function(data)
  local SkillMgr = require("Main.Skill.SkillMgr")
  SkillMgr.Instance():SyncAddTempSkillList(data.skillMap)
end
def.static("table").OnSSyncTempSkillListRemove = function(data)
  local SkillMgr = require("Main.Skill.SkillMgr")
  SkillMgr.Instance():SyncRemoveTempSkillList(data.skillId)
end
def.static("table").OnSSyncSkillCommonTip = function(data)
  print("OnSSyncSkillCommonTip")
  if data.res == data.class.NEED_MORE_SILVER then
    Toast(textRes.Skill[4])
  elseif data.res == data.class.BAG_FULL then
    Toast(textRes.Skill.LivingSkillMakeRes[0])
  elseif data.res == data.class.NEED_MORE_VIGOR then
    Toast(textRes.Skill.LivingSkillMakeRes[1])
  end
end
def.static("table").OnSSyncXiuLainSkillBagInfo = function(data)
  print("OnSSyncXiuLainSkillBagInfo")
  local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
  ExerciseSkillMgr.Instance():FillSkillBags(data)
end
def.static("table").OnSSyncSkillExpChange = function(data)
  local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
  local skillBag = ExerciseSkillMgr.Instance():GetSkillBag(data.skillBagId)
  local cfgData = skillBag:GetCfgData()
  local skillName = cfgData.skillCfg.name
  local xiuwei = tostring(data.exp)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local msgTable = {
    {
      PersonalHelper.Type.ColorText,
      skillName,
      "66ffcc"
    },
    {
      PersonalHelper.Type.Text,
      textRes.PersonalTip[3]
    },
    {
      PersonalHelper.Type.XiuLianExp,
      xiuwei
    }
  }
  if data.useSilver > 0 then
    table.insert(msgTable, {
      PersonalHelper.Type.Text,
      textRes.Skill[23]
    })
    table.insert(msgTable, {
      PersonalHelper.Type.Silver,
      data.useSilver
    })
  end
  PersonalHelper.CommonTableMsg(msgTable)
end
def.static("table").OnSSyncSkillInfo = function(data)
  print("OnSSyncSkillInfo")
  local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
  ExerciseSkillMgr.Instance():RawUpdateSkillBagInfo(data)
end
def.static("table").OnSSetDefaultSKillRes = function(data)
  print("SSetDefaultSKillRes")
  local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
  ExerciseSkillMgr.Instance():SyncDefaultSkillBag(data.skillBagId)
  local skillBag = ExerciseSkillMgr.Instance():GetSkillBag(data.skillBagId)
  local cfgData = skillBag:GetCfgData()
  Toast(string.format(textRes.Skill[13], cfgData.skillCfg.name))
end
def.static("table").OnSSyncXiuLainCommonInfo = function(data)
  print("OnSSyncXiuLainCommonInfo")
  Toast(textRes.Skill.SSyncCommonInfo[data.res])
end
def.static("table").OnSSyncGangSkillBagInfo = function(p)
  GangSkillData.Instance():SetSkillsLevel(p.skills)
end
def.static("table").OnSGangSkillLevelUpRes = function(p)
  GangSkillData.Instance():SetSkillLevel(p.skillInfo.skillid, p.skillInfo.level)
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.GANG_SKILL_LEVEL_UP_SUCCESS, {
    p.skillInfo.skillid,
    p.skillInfo.level
  })
end
def.static("table").OnSGangSkillError = function(p)
  local res = p.res
  if textRes.Skill.GangSkillRes[res] then
    Toast(textRes.Skill.GangSkillRes[res])
  end
end
return SkillModule.Commit()
