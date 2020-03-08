local Lplus = require("Lplus")
local YouthMgr = Lplus.Class("YouthMgr")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local def = YouthMgr.define
local instance
local PersonalHelper = require("Main.Chat.PersonalHelper")
def.field("table").tipsInFight = nil
def.static("=>", YouthMgr).Instance = function()
  if instance == nil then
    instance = YouthMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SSynChildrenAdulthoodInfoRes", YouthMgr.OnSSynChildrenAdulthoodInfoRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenSelectOccupationRes", YouthMgr.OnSChildrenSelectOccupationRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenSelectOccupationErrorRes", YouthMgr.OnSChildrenSelectOccupationErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SFightSkillOperRes", YouthMgr.OnSFightSkillOperRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SFightSkillOperErrorRes", YouthMgr.OnSFightSkillOperErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SAutoAddPotentialPrefErrorRes", YouthMgr.OnSAutoAddPotentialPrefErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SAutoAddPotentialPrefRes", YouthMgr.OnSAutoAddPotentialPrefRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SStudyCommonSkillSkillRes", YouthMgr.OnSStudyCommonSkillSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SLevelUpOccupationSkillRes", YouthMgr.OnSLevelUpOccupationSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SLevelUpOccupationSkillErrorRes", YouthMgr.OnSLevelUpOccupationSkillErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SUseChildrenGrowthItemRes", YouthMgr.OnSUseChildrenGrowthItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SUseChildrenGrowthItemErrorRes", YouthMgr.OnSUseChildrenGrowthItemErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SSynChildrenPropMapRes", YouthMgr.OnSSynChildrenPropMapRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SUnLockSkillPosErrorRes", YouthMgr.OnSUnLockSkillPosErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SUnLockSkillPosRes", YouthMgr.OnSUnLockSkillPosRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SStudyCommonSkillSkillErrorRes", YouthMgr.OnSStudyCommonSkillSkillErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SStudySpecialSkillRes", YouthMgr.OnSStudySpecialSkillRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SStudySpecialSkillErrorRes", YouthMgr.OnSStudySpecialSkillErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SResetAddPotentialPrefRes", YouthMgr.OnSResetAddPotentialPrefRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SResetAddPotentialPrefErrorRes", YouthMgr.OnSResetAddPotentialPrefErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SAddAptitudeRes", YouthMgr.OnSAddAptitudeRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SAddAptitudeErrorRes", YouthMgr.OnSAddAptitudeErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SUseChildrenCharaterItemRes", YouthMgr.OnSUseChildrenCharaterItemRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SUseChildrenCharaterItemErrorRes", YouthMgr.OnSUseChildrenCharaterItemErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SSynChildrenCharacterRes", YouthMgr.OnSSynChildrenCharacterRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenWearPetEquipErrorRes", YouthMgr.OnSChildrenWearPetEquipErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenWearPetEquipRes", YouthMgr.OnSChildrenWearPetEquipRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenEquipRandomRes", YouthMgr.OnSChildrenEquipRandomRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenEquipRandomErrorRes", YouthMgr.OnSChildrenEquipRandomErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenEquipLevelUpRes", YouthMgr.OnSChildrenEquipLevelUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenEquipStageUpErrorRes", YouthMgr.OnSChildrenEquipStageUpErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenEquipStageUpRes", YouthMgr.OnSChildrenEquipStageUpRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SSynChildrenLevelRes", YouthMgr.OnSSynChildrenLevelRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenEquipLevelUpErrorRes", YouthMgr.OnSChildrenEquipLevelUpErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenChangeOccupationErrorRes", YouthMgr.OnSChildrenChangeOccupationErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenChangeOccupationRes", YouthMgr.OnSChildrenChangeOccupationRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenRefreshAmuletErrorRes", YouthMgr.OnSChildrenRefreshAmuletErrorRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildrenRefreshAmuletRes", YouthMgr.OnSChildrenRefreshAmuletRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SUseAdulthoodChildrenCompensateSuccess", YouthMgr.OnSUseAdulthoodChildrenCompensateSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, YouthMgr.OnLeaveWorld)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.PET_REMOVED, YouthMgr.OnRemoveChild)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, YouthMgr.OnLeaveFight)
end
def.static().SayHello = function()
  local ChildFamilyLoveTipsEnum = require("consts.mzm.gsp.children.confbean.ChildFamilyLoveTipsEnum")
  local ChildPhase = require("consts.mzm.gsp.children.confbean.ChildPhase")
  local children = ChildrenDataMgr.Instance():GetChildrenByStatus(ChildPhase.YOUTH)
  if children == nil or #children == 0 then
    return
  end
  local randomIdx = math.random(#children)
  local child = children[randomIdx]
  if child then
    gmodule.moduleMgr:GetModule(ModuleId.CHILDREN):ShowChildSayHello(child.id, ChildFamilyLoveTipsEnum.ADULT_ON_LINE)
  end
end
def.static("table").OnSSynChildrenAdulthoodInfoRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    child_data:UpdateInfo(p.adulthoodInfo)
  end
end
def.static("table").OnSChildrenSelectOccupationRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    local preScore = child_data:CalYouthChildScore()
    child_data:SetMenpai(p.occupation)
    local nowScore = child_data:CalYouthChildScore()
    YouthMgr.CheckChildScoreChange(p.childrenid, preScore, nowScore)
    Toast(textRes.Children[3038])
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.SKILL_CHANGED, nil)
    local effRes = GetEffectRes(constant.CChildrenConsts.child_occupation_oper_effectid)
    if effRes then
      local name = tostring(constant.CChildrenConsts.child_occupation_oper_effectid)
      require("Fx.GUIFxMan").Instance():Play(effRes.path, name, 0, 0, -1, false)
    end
  end
end
def.static("table").OnSSynChildrenLevelRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    child_data.info.level = p.level
  end
end
def.static("table").OnSChildrenSelectOccupationErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3003])
  end
end
def.static("table").OnSFightSkillOperRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    child_data:SetFightSkill(p.skillid, p.use == 1)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Skill_Level_Updated, nil)
  end
end
def.static("table").OnSFightSkillOperErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_SKILL then
    Toast(textRes.Children[3004])
  elseif p.ret == p.ERROR_SKILL_MAX then
    Toast(textRes.Children[3005])
  elseif p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3006])
  end
end
def.static("table").OnSAutoAddPotentialPrefErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3007])
  elseif p.ret == p.ERROR_ALREADY_DID_IT then
    Toast(textRes.Children[3008])
  end
end
def.static("table").OnSAutoAddPotentialPrefRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    child_data:UpdatePropSet(p.propMap)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_SAVE_ASSIGN_PROP_SUCCESS, nil)
    Toast(textRes.Children[3021])
  end
end
def.static("table").OnSStudyCommonSkillSkillRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    local preScore = child_data:CalYouthChildScore()
    child_data:ChangeSkill(p.pos, p.skilid, p.replaceSkillid)
    local nowScore = child_data:CalYouthChildScore()
    YouthMgr.CheckChildScoreChange(p.childrenid, preScore, nowScore)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Common_Skill_Updated, nil)
    local childName = string.format("<font color=#00FF00>%s</font>", child_data.name)
    local PetUtility = require("Main.Pet.PetUtility")
    local skillName = PetUtility.Instance():GetPetSkillCfg(p.skilid).name
    local color = PetUtility.GetPetSkillQualityColor(p.skilid)
    local coloredskillName = string.format("<font color=#%s>%s</font>", color, skillName)
    local text = ""
    if p.replaceSkillid > 0 then
      local skillName = PetUtility.Instance():GetPetSkillCfg(p.replaceSkillid).name
      local color = PetUtility.GetPetSkillQualityColor(p.replaceSkillid)
      local coloredskillName2 = string.format("<font color=#%s>%s</font>", color, skillName)
      text = string.format(textRes.Pet.AddAndRemoveSkillReason[0], childName, coloredskillName, coloredskillName2)
    else
      text = string.format(textRes.Pet.AddSkillReason[0], childName, coloredskillName)
    end
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, text)
  end
end
def.static("table").OnSLevelUpOccupationSkillRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    local preScore = child_data:CalYouthChildScore()
    child_data:UpdateSkillLevel(p.skillid, p.lv)
    local nowScore = child_data:CalYouthChildScore()
    YouthMgr.CheckChildScoreChange(p.childrenid, preScore, nowScore)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Skill_Level_Updated, nil)
  end
end
def.static("table").OnSLevelUpOccupationSkillErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_SKILL then
    Toast(textRes.Children[3004])
  elseif p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3003])
  elseif p.ret == p.ERROR_ITEM_NOT_ENOUGH then
    Toast(textRes.Children[3009])
  elseif p.ret == p.ERROR_SKILL_TO_MAX_LEVEL then
    Toast(textRes.Children[3010])
  end
end
def.static("table").OnSUseChildrenGrowthItemRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    local preScore = child_data:CalYouthChildScore()
    local delta = p.growValue - child_data.info.grow
    delta = require("Common.MathHelper").Round(delta * 1000) / 1000
    child_data:SetGrowth(p.growValue)
    child_data:SetGrowthItemCount(p.useItemCount)
    local nowScore = child_data:CalYouthChildScore()
    YouthMgr.CheckChildScoreChange(p.childrenid, preScore, nowScore)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Growth_Updated, nil)
    Toast(string.format(textRes.Children[3047], child_data.name, tostring(delta)))
  end
end
def.static("table").OnSUseChildrenGrowthItemErrorRes = function(p)
  if p.ret == p.ERROR_GROWTH_TO_MAX then
    Toast(textRes.Children[3023])
  elseif p.ret == p.ERROR_ITEM_USE_TO_MAX then
    Toast(textRes.Children[3012])
  elseif p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3007])
  elseif p.ret == p.ERROR_DO_NOT_HAS_ITEM then
    Toast(textRes.Children[3009])
  end
end
def.static("table").OnSAddAptitudeRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    local preScore = child_data:CalYouthChildScore()
    local delta = p.aptValue - child_data.info.aptitudeInitMap[p.aptType]
    child_data:UpdateQuality(p.aptType, p.aptValue)
    local nowScore = child_data:CalYouthChildScore()
    YouthMgr.CheckChildScoreChange(p.childrenid, preScore, nowScore)
    Toast(string.format(textRes.Children[3048], child_data.name, textRes.Children.PropertyName[p.aptType], tostring(delta)))
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Quality_Updated, nil)
  end
end
def.static("table").OnSAddAptitudeErrorRes = function(p)
  if p.ret == p.ERROR_APTITUDE_FULL then
    Toast(textRes.Children[3011])
  elseif p.ret == p.ERROR_ITEM_USE_TO_MAX then
    Toast(textRes.Children[3012])
  elseif p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3007])
  elseif p.ret == p.ERROR_DO_NOT_HAS_ITEM then
    Toast(textRes.Children[3009])
  end
end
def.static("table").OnSSynChildrenPropMapRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    child_data:UpdateProps(p.propMap)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_PROP_UPDATED, nil)
  end
end
def.static("table").OnSUnLockSkillPosErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_ENOUGH_YUAN_BAO then
    Toast(textRes.Children[3013])
  elseif p.ret == p.ERROR_DO_NOT_HAS_ENOUGH_ITEM then
    Toast(textRes.Children[3009])
  elseif p.ret == p.ERROR_UNLOCK_TO_MAX then
    Toast(textRes.Children[3014])
  elseif p.ret == p.ERROR_ITEM_PRICE_CHANGED then
    Toast(textRes.Children[3015])
  end
end
def.static("table").OnSUnLockSkillPosRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    child_data:UpdateSkillNum(p.nowNum)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.SKILL_UNLOCKED, nil)
    Toast(textRes.Children[3056])
  end
end
def.static("table").OnSStudyCommonSkillSkillErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_ITEM then
    Toast(textRes.Children[3016])
  elseif p.ret == p.ERROR_DO_NOT_HAS_POSITION then
    Toast(textRes.Children[3017])
  elseif p.ret == p.ERROR_HAS_THIS_SKILL then
    Toast(textRes.Children[3018])
  elseif p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3007])
  end
end
def.static("table").OnSStudySpecialSkillRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data then
    local preScore = child_data:CalYouthChildScore()
    local old_skill_id = child_data.info.specialSkillid
    child_data:SetSpecialSkill(p.skilid)
    local nowScore = child_data:CalYouthChildScore()
    YouthMgr.CheckChildScoreChange(p.childrenid, preScore, nowScore)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.SKILL_CHANGED, nil)
    local childName = string.format("<font color=#00FF00>%s</font>", child_data.name)
    local SkillUtility = require("Main.Skill.SkillUtility")
    local skillCfg = SkillUtility.GetSkillCfg(p.skilid)
    local skillName = skillCfg and skillCfg.name
    local coloredskillName = string.format("<font color=#00FF00>%s</font>", skillName)
    local text = ""
    if old_skill_id > 0 then
      local skillName2 = SkillUtility.GetSkillCfg(old_skill_id).name
      local coloredskillName2 = string.format("<font color=#00FF00>%s</font>", skillName2)
      text = string.format(textRes.Children[3028], childName, coloredskillName, coloredskillName2)
    else
      text = string.format(textRes.Children[3027], childName, coloredskillName)
    end
    PersonalHelper.CommonMsg(PersonalHelper.Type.Text, text)
  end
end
def.static("table").OnSStudySpecialSkillErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_ITEM then
    Toast(textRes.Children[3016])
  elseif p.ret == p.ERROR_HAS_THIS_SKILL then
    Toast(textRes.Children[3018])
  elseif p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3007])
  end
end
def.static("table").OnSResetAddPotentialPrefRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.assignPropScheme then
    child_data:UpdatePropSet(nil)
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CLEAR_PROP_SET, nil)
  end
end
def.static("table").OnSResetAddPotentialPrefErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3007])
  elseif p.ret == p.ERROR_DO_NOT_HAS_PREF then
    Toast(textRes.Children[3019])
  elseif p.ret == p.ERROR_DO_NOT_HAS_ENOUGH_GOLD then
    Toast(textRes.Common[14])
  end
end
def.static("table").OnSSynChildrenCharacterRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    local delta = p.character - child_data.info.character
    child_data.info.character = p.character
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPDATE_CHARACTER, {delta})
    if p.tipType == p.TIP_TYPE_FIGHT then
      if instance.tipsInFight == nil then
        instance.tipsInFight = {}
      end
      instance.tipsInFight[p.childrenid:tostring()] = delta
    elseif delta > 0 then
      Toast(string.format(textRes.Children[3049], child_data.name, tostring(delta)))
    else
      Toast(string.format(textRes.Children[3050], child_data.name, tostring(math.abs(delta))))
    end
  end
end
def.method("userdata").TipCharacterChange = function(self, childId)
  if childId == nil or instance.tipsInFight == nil then
    return
  end
  local delta = instance.tipsInFight[childId:tostring()]
  if delta == nil then
    return
  end
  local child_data = ChildrenDataMgr.Instance():GetChildById(childId)
  if delta > 0 then
    Toast(string.format(textRes.Children[3049], child_data.name, tostring(delta)))
  else
    Toast(string.format(textRes.Children[3050], child_data.name, tostring(math.abs(delta))))
  end
end
def.static("table", "table").OnRemoveChild = function(p1, p2)
  local childId = p1 and p1.unit_id
  instance:TipCharacterChange(childId)
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  instance.tipsInFight = nil
end
def.static("table").OnSUseChildrenCharaterItemRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    child_data.info.character = p.character
  end
end
def.static("table").OnSUseChildrenCharaterItemErrorRes = function(p)
  if p.ret == p.ERROR_CHARACTER_TO_MAX then
    Toast(textRes.Children[3024])
  elseif p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3007])
  elseif p.ret == p.ERROR_DO_NOT_HAS_ITEM then
    Toast(textRes.Children[3016])
  end
end
def.static("table").OnSChildrenWearPetEquipErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_ITEM then
    Toast(textRes.Children[3033])
  elseif p.ret == p.ERROR_ITEM_NOT_SUIT then
    Toast(textRes.Children[3034])
  end
end
def.static("table").OnSChildrenWearPetEquipRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    local PetEquipType = require("consts.mzm.gsp.petequip.confbean.PetEquipType")
    child_data.info.equipPetItem[PetEquipType.AMULET] = p.itemInfo
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.UPDATE_PET_EQUIP, nil)
  end
end
def.static("table").OnSChildrenEquipRandomRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
    child_data.info.equipItem[p.pos].extraMap[ItemXStoreType.CHILDREN_EQUIP_PROP_A] = p.nowPropType
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.EQUIP_PROP_UPDATED, {
      child_data.info.equipItem[p.pos].id,
      ItemXStoreType.CHILDREN_EQUIP_PROP_A
    })
  end
end
def.static("table").OnSChildrenEquipRandomErrorRes = function(p)
  if p.ret == p.ERROR_ITEM_NOT_ENOUGH then
    Toast(textRes.Children[3009])
  elseif p.ret == p.ERROR_ITEM_NOT_SUIT then
    Toast(textRes.Children[3034])
  elseif p.ret == p.ERROR_MONEY_NOT_ENOUGH then
    Toast(textRes.Common[15])
  elseif p.ret == p.ERROR_DO_DO_NOT_HAS_OTHER_PROP then
    Toast(textRes.Children[3035])
  elseif p.ret == p.ERROR_POS_DO_NOT_HAS_EQUIP then
    Toast(textRes.Children[3036])
  elseif p.ret == p.ERROR_ITEM_PRICE_CHANGED then
    Toast(textRes.Children[3037])
  end
end
def.static("table").OnSChildrenEquipLevelUpRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    local preScore = child_data:CalYouthChildScore()
    local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
    local old_exp = child_data.info.equipItem[p.pos].extraMap[ItemXStoreType.CHILDREN_EQUIP_EXP]
    child_data.info.equipItem[p.pos].extraMap[ItemXStoreType.CHILDREN_EQUIP_EXP] = p.exp
    local exp_delta = p.exp - old_exp
    local oldLevel = child_data.info.equipItem[p.pos].extraMap[ItemXStoreType.CHILDREN_EQUIP_LEVEL]
    child_data.info.equipItem[p.pos].extraMap[ItemXStoreType.CHILDREN_EQUIP_LEVEL] = p.level
    local nowScore = child_data:CalYouthChildScore()
    YouthMgr.CheckChildScoreChange(p.childrenid, preScore, nowScore)
    local params
    if oldLevel < p.level then
      params = {
        child_data.info.equipItem[p.pos].id,
        ItemXStoreType.CHILDREN_EQUIP_LEVEL,
        old_level = oldLevel,
        new_level = p.level,
        exp_delta = exp_delta
      }
    else
      params = {
        child_data.info.equipItem[p.pos].id,
        ItemXStoreType.CHILDREN_EQUIP_EXP,
        exp_delta = exp_delta
      }
    end
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.EQUIP_PROP_UPDATED, params)
  end
end
def.static("table").OnSChildrenEquipStageUpErrorRes = function(p)
  if p.ret == p.ERROR_ITEM_NOT_ENOUGH then
    Toast(textRes.Children[3009])
  elseif p.ret == p.ERROR_ITEM_NOT_SUIT then
    Toast(textRes.Children[3034])
  elseif p.ret == p.ERROR_MONEY_NOT_ENOUGH then
    Toast(textRes.Common[15])
  elseif p.ret == p.ERROR_DO_DO_NOT_HAS_OTHER_PROP then
    Toast(textRes.Children[3035])
  elseif p.ret == p.ERROR_POS_DO_NOT_HAS_EQUIP then
    Toast(textRes.Children[3036])
  elseif p.ret == p.ERROR_LEVEL_NOT_ENOUGH then
    Toast(textRes.Children[3037])
  end
end
def.static("table").OnSChildrenEquipStageUpRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
    child_data.info.equipItem[p.pos].extraMap[ItemXStoreType.CHILDREN_EQUIP_STAGE] = p.stage
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.EQUIP_PROP_UPDATED, {
      child_data.info.equipItem[p.pos].id,
      ItemXStoreType.CHILDREN_EQUIP_STAGE
    })
  end
end
def.static("table").OnSChildrenEquipLevelUpErrorRes = function(p)
  if p.ret == p.ERROR_ITEM_NOT_ENOUGH then
    Toast(textRes.Children[3009])
  elseif p.ret == p.ERROR_ITEM_NOT_SUIT then
    Toast(textRes.Children[3034])
  elseif p.ret == p.ERROR_POS_DO_NOT_HAS_EQUIP then
    Toast(textRes.Children[3036])
  elseif p.ret == p.ERROR_TO_MAX_LEVEL then
    Toast(textRes.Children[3053])
  elseif p.ret == p.ERROR_STAGE_NOT_ENOUGH then
    Toast(textRes.Children[3054])
  elseif p.ret == p.ERROR_NOT_OVER_CHILDREN_LEVEL then
    Toast(textRes.Children[3055])
  end
end
def.static("table").OnSChildrenChangeOccupationErrorRes = function(p)
  if p.ret == p.ERROR_DO_NOT_HAS_OCCUPATION then
    Toast(textRes.Children[3057])
  elseif p.ret == p.ERROR_DO_NOT_HAS_ENOUGH_MONEY then
    Toast(textRes.Common[14])
  elseif p.ret == p.ERROR_DO_CHILD_IN_FIGHT_NOW then
    Toast(textRes.Children[3058])
  end
end
def.static("table").OnSChildrenChangeOccupationRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    child_data.info.occupation = p.occupation
    child_data.info.occupationSkill2Value = p.skill2lv
    child_data.info.fightSkills = p.fightSkills
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.MENPAI_CHANGED, nil)
    local effRes = GetEffectRes(constant.CChildrenConsts.child_occupation_oper_effectid)
    if effRes then
      local name = tostring(constant.CChildrenConsts.child_occupation_oper_effectid)
      require("Fx.GUIFxMan").Instance():Play(effRes.path, name, 0, 0, -1, false)
    end
    Toast(textRes.Children[3073])
  end
end
def.method("userdata", "number").AmuletRefreshReq = function(self, childId, useYuanbao)
  local pro = require("netio.protocol.mzm.gsp.Children.CChildrenRefreshAmuletReq").new()
  pro.childrenid = childId
  if useYuanbao <= 0 then
    pro.costType = pro.UNUSE
    pro.costYuanBao = 0
  else
    pro.costType = pro.USE
    pro.costYuanBao = useYuanbao
  end
  pro.yuanBaoNum = gmodule.moduleMgr:GetModule(ModuleId.ITEM):GetAllYuanBao()
  gmodule.network.sendProtocol(pro)
end
def.static("table").OnSChildrenRefreshAmuletErrorRes = function(p)
  if p.ret == p.ERROR_ITEM_NOT_ENOUGH then
    Toast(textRes.Children[3009])
  elseif p.ret == p.ERROR_ITEM_NOT_SUIT then
    Toast(textRes.Children[3034])
  elseif p.ret == p.ERROR_POS_DO_NOT_HAS_EQUIP then
    Toast(textRes.Children[3036])
  elseif p.ret == p.ERROR_YUANBAO_NOT_ENOUGH then
    Toast(textRes.Common[15])
  elseif p.ret == p.ERROR_ITEM_PRICE_CHANGED then
    Toast(textRes.Children[3037])
  end
end
def.static("table").OnSChildrenRefreshAmuletRes = function(p)
  local child_data = ChildrenDataMgr.Instance():GetChildById(p.childrenid)
  if child_data and child_data.info then
    local ItemXStoreType = require("netio.protocol.mzm.gsp.item.ItemXStoreType")
    local PetEquipType = require("consts.mzm.gsp.petequip.confbean.PetEquipType")
    local amuletInfo = child_data.info.equipPetItem[PetEquipType.AMULET]
    if amuletInfo == nil then
      return nil
    end
    amuletInfo.extraMap[ItemXStoreType.PET_EQUIP_SKILL_ID_1] = p.skillids[1]
    amuletInfo.extraMap[ItemXStoreType.PET_EQUIP_SKILL_ID_2] = p.skillids[2]
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.AMULET_SKILL_CHANGED, nil)
    Toast(textRes.Children[3076])
    Event.DispatchEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_REFRESH_AMULET_SUCCESS, nil)
  end
end
def.static("table", "table").OnLeaveWorld = function(p1, p2)
  instance.tipsInFight = nil
end
def.static("userdata", "number", "number").CheckChildScoreChange = function(childId, preScore, nowScore)
  if preScore ~= nowScore then
    local params = {}
    params.childId = childId
    params.preScore = preScore
    params.nowScore = nowScore
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHILD_SCORE_CHANGE, params)
  end
end
def.method("userdata").CompensateYouthChild = function(self, uuid)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CUseAdulthoodChildrenCompensate").new(uuid))
end
def.static("table").OnSUseAdulthoodChildrenCompensateSuccess = function(p)
  Toast(textRes.Children[3081])
end
YouthMgr.Commit()
return YouthMgr
