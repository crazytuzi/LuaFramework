local Lplus = require("Lplus")
local MountsPanelNodeBase = require("Main.Mounts.ui.MountsPanelNodeBase")
local ECPanelBase = require("GUI.ECPanelBase")
local BasicAttrNode = Lplus.Extend(MountsPanelNodeBase, "BasicAttrNode")
local GUIUtils = require("GUI.GUIUtils")
local Vector = require("Types.Vector")
local Vector3 = require("Types.Vector3").Vector3
local MountsUtils = require("Main.Mounts.MountsUtils")
local MountsMgr = require("Main.Mounts.mgr.MountsMgr")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local MountsUIModel = require("Main.Mounts.MountsUIModel")
local SkillUtility = require("Main.Skill.SkillUtility")
local SkillTipMgr = require("Main.Skill.SkillTipMgr")
local MountsTypeEnum = require("consts.mzm.gsp.mounts.confbean.MountsTypeEnum")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local ItemColor = require("consts.mzm.gsp.item.confbean.Color")
local def = BasicAttrNode.define
def.field("table").uiObjs = nil
def.field(MountsUIModel).modelInSX = nil
def.field(MountsUIModel).modelAfterInSJ = nil
def.field("boolean").isDragSXModel = false
def.field("boolean").isDragSJModelPre = false
def.field("boolean").isDragSJModelAfter = false
def.field("boolean").hasEnoughMaterial = false
def.field("boolean").useYuanbao = false
def.field("number").needYuanbao = 0
def.field("number").needItemType = -1
def.field("number").needItemNum = 0
def.field("number").hasItemNum = 0
def.field("number").calItemId = 0
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  MountsPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  Event.RegisterEventWithContext(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsAddScoreSuccess, BasicAttrNode.OnMountsAddScoreSuccess, self)
  Event.RegisterEventWithContext(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsRankUpSuccess, BasicAttrNode.OnMountsRankUpSuccess, self)
  Event.RegisterEventWithContext(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, BasicAttrNode.OnBagInfoSynchronized, self)
end
def.override().OnHide = function(self)
  self:Clear()
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsAddScoreSuccess, BasicAttrNode.OnMountsAddScoreSuccess)
  Event.UnregisterEvent(ModuleId.MOUNTS, gmodule.notifyId.Mounts.MountsRankUpSuccess, BasicAttrNode.OnMountsRankUpSuccess)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, BasicAttrNode.OnBagInfoSynchronized)
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.isDragSXModel = false
  self.isDragSJModelPre = false
  self.isDragSJModelAfter = false
  if self.modelInSX ~= nil then
    self.modelInSX:Destroy()
    self.modelInSX = nil
  end
  if self.modelAfterInSJ ~= nil then
    self.modelAfterInSJ:Destroy()
    self.modelAfterInSJ = nil
  end
  self.hasEnoughMaterial = false
  self.useYuanbao = false
  self.needYuanbao = 0
  self.needItemType = -1
  self.needItemNum = 0
  self.hasItemNum = 0
  self.calItemId = 0
end
def.method().InitUI = function(self)
  if not self.m_node or self.m_node.isnil then
    return
  end
  self.uiObjs = {}
  self.uiObjs.Tap_SX = self.m_node:FindDirect("Tap_SX")
  self.uiObjs.Tap_JN = self.m_node:FindDirect("Tap_JN")
  self.uiObjs.Tap_SJ = self.m_node:FindDirect("Tap_SJ")
  self.uiObjs.Tap_WG = self.m_node:FindDirect("Tap_WG")
  GUIUtils.SetActive(self.uiObjs.Tap_WG, false)
  self.uiObjs.SX = self.m_node:FindDirect("SX")
  self.uiObjs.Img_SX_Bg0 = self.uiObjs.SX:FindDirect("Img_SX_Bg0")
  self.uiObjs.Btn_Switch = self.uiObjs.SX:FindDirect("Btn_Switch")
  self.uiObjs.JN = self.m_node:FindDirect("JN")
  self.uiObjs.SJ = self.m_node:FindDirect("SJ")
end
def.override("userdata").ChooseMounts = function(self, mountsId)
  if not self.isShow then
    return
  end
  MountsPanelNodeBase.ChooseMounts(self, mountsId)
  self:ShowMountsBasicInfo()
  self:SetMountsRankProgress()
  self:SetSJCost()
  self:SetButtonStatus()
end
def.method().ShowMountsBasicInfo = function(self)
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts == nil then
    self:NoMounts()
    return
  end
  local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
  local mountsRankCfg = MountsUtils.GetMountsCfgOfRank(mounts.mounts_cfg_id, mounts.mounts_rank)
  if mountsCfg == nil or mountsRankCfg == nil then
    return
  end
  if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
    self.uiObjs.Tap_SX:GetComponent("UIToggle").value = true
    GUIUtils.SetActive(self.uiObjs.SX, true)
    GUIUtils.SetActive(self.uiObjs.JN, false)
    GUIUtils.SetActive(self.uiObjs.SJ, false)
  end
  local Img_SX_Bg0 = self.uiObjs.Img_SX_Bg0:FindDirect("Img_SX_Bg0")
  local Group_Attribute = self.uiObjs.Img_SX_Bg0:FindDirect("Group_Attribute")
  local Group_Power = self.uiObjs.Img_SX_Bg0:FindDirect("Group_Power")
  local MountsName = Img_SX_Bg0:FindDirect("Label_JieShu")
  local Label_PowerNum = Group_Power:FindDirect("Label_PowerNum")
  local Img_Type = self.uiObjs.SX:FindDirect("Img_Type")
  local Label_RidingSpeed = self.uiObjs.SX:FindDirect("Label_RidingSpeed")
  local Label_RidingSpeedNumber = self.uiObjs.SX:FindDirect("Label_RidingSpeedNumber")
  local Btn_Promote = Group_Power:FindDirect("Btn_Promote")
  local bornSpeed = require("Main.Hero.HeroUtility").Instance():GetRoleCommonConsts("BORN_MOVE_SPEED") or 0
  local Group_StarAttribute = self.uiObjs.Img_SX_Bg0:FindDirect("Group_StarAttribute")
  local Label_StarTitle = self.uiObjs.Img_SX_Bg0:FindDirect("Label_StarTitle")
  local Btn_Star = self.uiObjs.SX:FindDirect("Btn_Star")
  local Label_RidingType = self.uiObjs.SX:FindDirect("Label_RidingType")
  local Label_RidingTypeNumber = self.uiObjs.SX:FindDirect("Label_RidingTypeNumber")
  GUIUtils.SetActive(Btn_Promote, false)
  GUIUtils.SetActive(Img_Type, true)
  GUIUtils.SetSprite(Img_Type, textRes.Mounts.MountsTypeSprite[mountsCfg.mountsType])
  GUIUtils.SetText(Label_PowerNum, MountsMgr.Instance():GetMountsScore(self.curMountsId))
  GUIUtils.SetActive(Label_RidingType, true)
  GUIUtils.SetText(Label_RidingTypeNumber, mountsCfg.maxMountRoleNum)
  if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
    GUIUtils.SetText(MountsName, mountsCfg.mountsName)
  else
    GUIUtils.SetText(MountsName, string.format(textRes.Mounts[60], mountsCfg.mountsName, mounts.mounts_rank))
  end
  GUIUtils.SetActive(Label_RidingSpeed, true)
  if bornSpeed == 0 then
    GUIUtils.SetText(Label_RidingSpeedNumber, "")
  else
    local maxSpeed = MountsMgr.Instance():GetMountsMaxMoveSpeed()
    if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
      if maxSpeed > mountsRankCfg.speed then
        local addPercent = (maxSpeed - bornSpeed) / bornSpeed * 100
        GUIUtils.SetText(Label_RidingSpeedNumber, string.format(textRes.Mounts[135], addPercent))
      else
        local addPercent = (mountsRankCfg.speed - bornSpeed) / bornSpeed * 100
        GUIUtils.SetText(Label_RidingSpeedNumber, string.format("+%d%%", addPercent))
      end
    else
      local addPercent = (mountsRankCfg.speed - bornSpeed) / bornSpeed * 100
      GUIUtils.SetText(Label_RidingSpeedNumber, string.format("+%d%%", addPercent))
    end
  end
  GUIUtils.SetActive(Btn_Star, true)
  if Group_Attribute:GetComponent("UIGrid") ~= nil then
    Group_Attribute:GetComponent("UIGrid"):set_enabled(false)
  end
  local lableSXNumInPanel = 3
  local attrIndex = 1
  local propertyMap = mountsRankCfg.property
  for k, v in pairs(propertyMap) do
    local Img_CW_BgAttribute = Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d", attrIndex))
    GUIUtils.SetActive(Img_CW_BgAttribute, true)
    local valueLabel = Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", attrIndex, attrIndex))
    local nameLabel = Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", attrIndex, attrIndex))
    local propertyCfg = _G.GetCommonPropNameCfg(k)
    if valueLabel and nameLabel and propertyCfg then
      local propertyName = propertyCfg.propName
      GUIUtils.SetActive(nameLabel, true)
      GUIUtils.SetActive(valueLabel, true)
      GUIUtils.SetText(nameLabel, propertyName)
      GUIUtils.SetText(valueLabel, v)
      attrIndex = attrIndex + 1
    end
  end
  for i = attrIndex, lableSXNumInPanel do
    local Img_CW_BgAttribute = Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d", i))
    GUIUtils.SetActive(Img_CW_BgAttribute, false)
    local valueLabel = Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", i, i))
    local nameLabel = Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", i, i))
    GUIUtils.SetText(nameLabel, "")
    GUIUtils.SetText(valueLabel, "")
  end
  local curStarLevel = mounts.current_star_level
  local curStarNum = mounts.current_max_active_star_num
  local starProperty = {}
  local mountsStartMapCfg = MountsUtils.GetMountsStartLifeMapCfg(mounts.mounts_cfg_id)
  local starCount = 0
  if mountsStartMapCfg ~= nil then
    starCount = #mountsStartMapCfg
  end
  if curStarLevel > 1 and curStarNum == 0 then
    curStarLevel = curStarLevel - 1
    curStarNum = starCount
  end
  local mountsStarCfg = MountsUtils.GetMountsStartLifeCfgById(mounts.mounts_cfg_id)
  if mountsStarCfg ~= nil then
    for i = 1, starCount do
      local isActive = true
      local cfg
      if mountsStarCfg[i] ~= nil then
        if curStarLevel <= 1 then
          cfg = mountsStarCfg[i][1]
          if i > curStarNum then
            isActive = false
          end
        elseif i <= curStarNum then
          cfg = mountsStarCfg[i][curStarLevel]
        elseif i > curStarNum then
          cfg = mountsStarCfg[i][curStarLevel - 1]
        end
      end
      if cfg ~= nil then
        local property = cfg.propertyList[1]
        if property ~= nil then
          local showProperty = {}
          showProperty.nameKey = property.nameKey
          showProperty.isActive = isActive
          showProperty.value = property.value
          starProperty[#starProperty + 1] = showProperty
        end
      end
    end
  end
  local lableStarNumInPanel = 5
  local attrStarIndex = 1
  local starPropertyMap = starProperty
  for k, v in pairs(starPropertyMap) do
    local valueLabel = Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", attrStarIndex, attrStarIndex))
    local nameLabel = Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", attrStarIndex, attrStarIndex))
    local Label_Active = Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_Active", attrStarIndex))
    local propertyCfg = _G.GetCommonPropNameCfg(v.nameKey)
    if valueLabel and nameLabel and propertyCfg then
      local propertyName = propertyCfg.propName
      GUIUtils.SetActive(nameLabel, true)
      GUIUtils.SetActive(valueLabel, true)
      GUIUtils.SetActive(Label_Active, false)
      GUIUtils.SetText(nameLabel, propertyName)
      if v.isActive then
        GUIUtils.SetText(valueLabel, v.value)
      else
        GUIUtils.SetText(valueLabel, textRes.Mounts[110])
      end
      attrStarIndex = attrStarIndex + 1
    end
  end
  GUIUtils.SetActive(Label_StarTitle, attrStarIndex > 1)
  for i = attrStarIndex, lableStarNumInPanel do
    local valueLabel = Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", i, i))
    local nameLabel = Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", i, i))
    local Label_Active = Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_Active", i))
    GUIUtils.SetText(nameLabel, "")
    GUIUtils.SetText(valueLabel, "")
    GUIUtils.SetActive(Label_Active, false)
  end
  local tabs = {
    self.uiObjs.Tap_SX,
    self.uiObjs.Tap_JN,
    self.uiObjs.Tap_SJ
  }
  for i = 1, #tabs do
    local toggleObject = tabs[i]:GetComponent("UIToggledObjects")
    toggleObject:set_enabled(true)
  end
  local Model_CW = Img_SX_Bg0:FindDirect("Model_CW")
  local uiModel = Model_CW:GetComponent("UIModel")
  if self.modelInSX ~= nil then
    self.modelInSX:Destroy()
  end
  self.modelInSX = MountsUtils.LoadMountsModel(uiModel, mounts.mounts_cfg_id, mounts.current_ornament_rank, mounts.color_id, function()
    if self.modelInSX ~= nil then
      self.modelInSX:SetScale(0.8)
      self.modelInSX:SetDir(-135)
    end
  end)
  local mountsMgr = MountsMgr.Instance()
  local curRideMountsId = mountsMgr:GetCurRideMountsId()
  GUIUtils.SetActive(self.uiObjs.Btn_Switch, true)
  if curRideMountsId ~= nil and Int64.eq(self.curMountsId, curRideMountsId) then
    GUIUtils.SetText(self.uiObjs.Btn_Switch:FindDirect("Label_Switch"), textRes.Mounts[98])
  else
    GUIUtils.SetText(self.uiObjs.Btn_Switch:FindDirect("Label_Switch"), textRes.Mounts[99])
  end
  local JNGroup_Skill = self.uiObjs.JN:FindDirect("Group_Skill")
  local Img_ZhudongSkill = JNGroup_Skill:FindDirect("Img_ZhudongSkill")
  local Img_ZhudongSkillName = Img_ZhudongSkill:FindDirect("Label_SkillName")
  local ZhudongSkillIcon = Img_ZhudongSkill:FindDirect("Img_JN_IconSkill")
  local ZhuDong_Title = JNGroup_Skill:FindDirect("Label")
  local zhudongSkillDesc = textRes.Mounts[90]
  local skillId = 0
  local skillLevel = 0
  local needGray = false
  GUIUtils.SetItemCellSprite(Img_ZhudongSkill, MountsUtils.GetMountsSkillColor(mountsRankCfg.activeSkillIconColor))
  local mountsActiveSkillRankCfg = MountsUtils.GetMountsActiveSkillRankChange(mounts.mounts_cfg_id)
  if mountsActiveSkillRankCfg[mounts.mounts_rank] ~= nil then
    local curSkill = mountsActiveSkillRankCfg[mounts.mounts_rank]
    if curSkill ~= nil then
      if curSkill.skillId == 0 then
        if curSkill.nextSkillRank ~= nil then
          local nextSkill = mountsActiveSkillRankCfg[curSkill.nextSkillRank]
          if nextSkill ~= nil then
            skillId = nextSkill.skillId
            skillLevel = nextSkill.skillLevel
            needGray = true
          end
        end
      else
        skillId = curSkill.skillId
        skillLevel = curSkill.skillLevel
      end
    end
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  if skillCfg ~= nil then
    GUIUtils.FillIcon(ZhudongSkillIcon:GetComponent("UITexture"), skillCfg.iconId)
    if needGray then
      GUIUtils.SetTextureEffect(ZhudongSkillIcon:GetComponent("UITexture"), GUIUtils.Effect.Gray)
    else
      GUIUtils.SetTextureEffect(ZhudongSkillIcon:GetComponent("UITexture"), GUIUtils.Effect.Normal)
    end
  else
    GUIUtils.FillIcon(ZhudongSkillIcon:GetComponent("UITexture"), 0)
  end
  GUIUtils.SetText(Img_ZhudongSkillName, zhudongSkillDesc)
  GUIUtils.SetText(ZhuDong_Title, string.format(textRes.Mounts[111], skillLevel))
  local unlockSkillRank = MountsUtils.GetMountsSortedUnlockPassiveSkillRank(mounts.mounts_cfg_id)
  local passiveNumInJN = 3
  for i = 1, passiveNumInJN do
    local passiveSkill = JNGroup_Skill:FindDirect(string.format("Img_BeidongSkill_%d", i))
    if unlockSkillRank[i] == nil then
      GUIUtils.SetActive(passiveSkill, false)
    else
      GUIUtils.SetActive(passiveSkill, true)
      local skill = mounts.passive_skill_list[i]
      if skill ~= nil and mounts.mounts_rank >= unlockSkillRank[i] then
        local skillCfg = SkillUtility.GetSkillCfg(skill.current_passive_skill_cfg_id)
        GUIUtils.SetText(passiveSkill:FindDirect("Label_SkillName"), skillCfg.name)
        GUIUtils.FillIcon(passiveSkill:FindDirect("Img_JN_IconSkill"):GetComponent("UITexture"), skillCfg.iconId)
        local passiveSkillCfg = MountsUtils.GetMountsPassiveSkillCfgByMountsIdAndSkillId(mounts.mounts_cfg_id, skill.current_passive_skill_cfg_id)
        if passiveSkillCfg ~= nil then
          GUIUtils.SetItemCellSprite(passiveSkill, MountsUtils.GetMountsSkillColor(passiveSkillCfg.passiveSkillIconColor))
        else
          GUIUtils.SetItemCellSprite(passiveSkill, ItemColor.WHITE)
        end
      else
        GUIUtils.SetText(passiveSkill:FindDirect("Label_SkillName"), string.format(textRes.Mounts[9], unlockSkillRank[i]))
        GUIUtils.FillIcon(passiveSkill:FindDirect("Img_JN_IconSkill"):GetComponent("UITexture"), 0)
        GUIUtils.SetItemCellSprite(passiveSkill, ItemColor.WHITE)
      end
    end
  end
  local Model_After = self.uiObjs.SJ:FindDirect("Model_After")
  local uiModelAfter = Model_After:GetComponent("UIModel")
  if self.modelAfterInSJ ~= nil and self.modelAfterInSJ ~= nil then
    self.modelAfterInSJ:Destroy()
  end
  self.modelAfterInSJ = MountsUtils.LoadMountsModel(uiModelAfter, mounts.mounts_cfg_id, math.min(mounts.mounts_rank + 1, constant.CMountsConsts.maxMountsRank), mounts.color_id, function()
    if self.modelAfterInSJ ~= nil then
      self.modelAfterInSJ:SetScale(0.8)
      self.modelAfterInSJ:SetDir(-135)
    end
  end)
  local Label_ModelTitle = self.uiObjs.SJ:FindDirect("Labe111")
  local Label_ShuxingTitle = self.uiObjs.SJ:FindDirect("Label_ShuxingTitle")
  local JNGroup_Attribute = self.uiObjs.SJ:FindDirect("Group_Attribute")
  local Label_Next = self.uiObjs.SJ:FindDirect("Label_Next")
  local nextRankCfg = MountsUtils.GetMountsCfgOfRank(mounts.mounts_cfg_id, mounts.mounts_rank + 1)
  if nextRankCfg == nil then
    GUIUtils.SetText(Label_ModelTitle, textRes.Mounts[95])
    GUIUtils.SetText(Label_ShuxingTitle, textRes.Mounts[93])
    GUIUtils.SetText(Label_Next, textRes.Mounts[96])
    nextRankCfg = mountsRankCfg
  else
    GUIUtils.SetText(Label_ModelTitle, textRes.Mounts[94])
    GUIUtils.SetText(Label_ShuxingTitle, textRes.Mounts[92])
    local unlockPassiveSkillLevel = MountsUtils.GetMountsSortedUnlockPassiveSkillRank(mounts.mounts_cfg_id)
    local hasUnlockPassiveSkill = false
    for i = 1, #unlockPassiveSkillLevel do
      if mounts.mounts_rank + 1 == unlockPassiveSkillLevel[i] then
        hasUnlockPassiveSkill = true
        break
      end
    end
    local hasUnlockActiveSkill = false
    local hasStrengthActiveSkill = false
    if not hasUnlockPassiveSkill then
      local activeSkillCfg = MountsUtils.GetMountsActiveSkillRankChange(mounts.mounts_cfg_id)
      if activeSkillCfg[mounts.mounts_rank + 1] ~= nil then
        if activeSkillCfg[mounts.mounts_rank] == nil or activeSkillCfg[mounts.mounts_rank].skillId ~= activeSkillCfg[mounts.mounts_rank + 1].skillId then
          hasUnlockActiveSkill = true
        elseif activeSkillCfg[mounts.mounts_rank] ~= nil and activeSkillCfg[mounts.mounts_rank].skillId == activeSkillCfg[mounts.mounts_rank + 1].skillId and activeSkillCfg[mounts.mounts_rank].skillLevel < activeSkillCfg[mounts.mounts_rank + 1].skillLevel then
          hasStrengthActiveSkill = true
        end
      end
    end
    local desc = ""
    if hasUnlockPassiveSkill then
      desc = string.format(textRes.Mounts[100], mounts.mounts_rank + 1)
    elseif hasUnlockActiveSkill then
      desc = textRes.Mounts[101]
    elseif hasStrengthActiveSkill then
      desc = textRes.Mounts[102]
    else
      desc = textRes.Mounts[122]
    end
    GUIUtils.SetText(Label_Next, desc)
  end
  local nextProperty = {}
  for k, v in pairs(nextRankCfg.property) do
    nextProperty[k] = v
  end
  local attrNumInSJ = 2
  local attrSJIndex = 1
  for k, v in pairs(nextProperty) do
    local nameLabel = JNGroup_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", attrSJIndex, attrSJIndex))
    local valueLabel = JNGroup_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", attrSJIndex, attrSJIndex))
    local propertyCfg = _G.GetCommonPropNameCfg(k)
    if nameLabel and valueLabel and propertyCfg then
      local propertyName = propertyCfg.propName
      GUIUtils.SetText(nameLabel, propertyName)
      GUIUtils.SetText(valueLabel, v)
      attrSJIndex = attrSJIndex + 1
    end
  end
  for i = attrSJIndex, attrNumInSJ do
    local valueLabel = JNGroup_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", i, i))
    local nameLabel = JNGroup_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", i, i))
    GUIUtils.SetText(nameLabel, "")
    GUIUtils.SetText(valueLabel, "")
  end
end
def.method().SetMountsRankProgress = function(self)
  local Group_Slide = self.uiObjs.SJ:FindDirect("Group_Slide")
  local Label_ExpNum = Group_Slide:FindDirect("Label_ExpNum")
  local Img_Bg = Group_Slide:FindDirect("Img_Bg")
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts == nil then
    GUIUtils.SetActive(Group_Slide, false)
    return
  end
  local mountsNextRankCfg = MountsUtils.GetMountsCfgOfRank(mounts.mounts_cfg_id, mounts.mounts_rank + 1)
  if mountsNextRankCfg == nil then
    GUIUtils.SetActive(Group_Slide, false)
    return
  end
  if mounts.current_score >= mountsNextRankCfg.rankUpNeedScoreNum then
    GUIUtils.SetActive(Group_Slide, false)
  else
    GUIUtils.SetActive(Group_Slide, true)
    GUIUtils.SetText(Label_ExpNum, string.format("%d/%d", mounts.current_score, mountsNextRankCfg.rankUpNeedScoreNum))
    GUIUtils.SetProgress(Img_Bg, GUIUtils.COTYPE.SLIDER, math.min(mounts.current_score / mountsNextRankCfg.rankUpNeedScoreNum, 1))
  end
end
def.method().SetSJCost = function(self)
  local Img_BgItem = self.uiObjs.SJ:FindDirect("Img_BgItem")
  local Label_Name = Img_BgItem:FindDirect("Label_Name")
  local Icon_Item = Img_BgItem:FindDirect("Icon_Item")
  local Label_Num = Img_BgItem:FindDirect("Label_Num")
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts == nil then
    GUIUtils.SetActive(Img_BgItem, false)
    return
  end
  local mountsNextRankCfg = MountsUtils.GetMountsCfgOfRank(mounts.mounts_cfg_id, mounts.mounts_rank + 1)
  if mountsNextRankCfg == nil then
    GUIUtils.SetActive(Img_BgItem, false)
    return
  end
  if mounts.current_score < mountsNextRankCfg.rankUpNeedScoreNum then
    GUIUtils.SetActive(Img_BgItem, false)
    return
  end
  GUIUtils.SetActive(Img_BgItem, true)
  self.hasEnoughMaterial = false
  local needItemType = mountsNextRankCfg.rankUpcostItemType
  local needNum = mountsNextRankCfg.rankUpCostItemIdNum
  local needItemList = ItemUtils.GetItemTypeRefIdList(needItemType)
  if needItemList ~= nil then
    local itemBase = ItemUtils.GetItemBase(needItemList[1])
    if itemBase ~= nil then
      GUIUtils.FillIcon(Icon_Item:GetComponent("UITexture"), itemBase.icon)
      local hasNum = 0
      local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, needItemType)
      for k, v in pairs(items) do
        hasNum = hasNum + v.number
      end
      self.needItemType = needItemType
      self.needItemNum = needNum
      self.hasItemNum = hasNum
      self.calItemId = needItemList[1]
      if needNum > hasNum then
        GUIUtils.SetText(Label_Num, string.format("[ff0000]%d/%d[-]", hasNum, needNum))
      else
        GUIUtils.SetText(Label_Num, string.format("%d/%d", hasNum, needNum))
        self.hasEnoughMaterial = true
      end
      GUIUtils.SetText(Label_Name, itemBase.name)
    end
  end
end
def.method().SetButtonStatus = function(self)
  local Btn_Jinjie = self.uiObjs.SJ:FindDirect("Btn_Jinjie")
  local Group_Yuanbao = Btn_Jinjie:FindDirect("Group_Yuanbao")
  local Label_Money = Group_Yuanbao:FindDirect("Label_Money")
  local Label = Btn_Jinjie:FindDirect("Label")
  if MountsMgr.Instance():IsMoutsReachMaxRank(self.curMountsId) then
    GUIUtils.SetActive(Btn_Jinjie, false)
    return
  end
  GUIUtils.SetActive(Btn_Jinjie, true)
  if not MountsMgr.Instance():IsMountsRankUpScoreFull(self.curMountsId) then
    GUIUtils.SetActive(Label, true)
    GUIUtils.SetText(Label, textRes.Mounts[82])
    GUIUtils.SetActive(Group_Yuanbao, false)
  else
    if not self.useYuanbao or self.hasEnoughMaterial then
      GUIUtils.SetActive(Label, true)
      GUIUtils.SetText(Label, textRes.Mounts[81])
      GUIUtils.SetActive(Group_Yuanbao, false)
    else
      require("Main.Item.ItemConsumeHelper").Instance():GetItemYuanBaoPrice(self.calItemId, function(result)
        if self.m_panel == nil or self.m_panel.isnil then
          return
        end
        self.needYuanbao = result * (self.needItemNum - self.hasItemNum)
        GUIUtils.SetActive(Label, false)
        GUIUtils.SetActive(Group_Yuanbao, true)
        GUIUtils.SetText(Label_Money, self.needYuanbao)
      end)
    end
    local Img_BgItem = self.uiObjs.SJ:FindDirect("Img_BgItem")
    local Btn_UseGold = Img_BgItem:FindDirect("Btn_UseGold")
    Btn_UseGold:GetComponent("UIToggle").value = self.useYuanbao
  end
end
def.method().ClickUseYuanbao = function(self)
  local Img_BgItem = self.uiObjs.SJ:FindDirect("Img_BgItem")
  local Btn_UseGold = Img_BgItem:FindDirect("Btn_UseGold")
  if not Btn_UseGold:GetComponent("UIToggle").value then
    self.useYuanbao = false
    self:SetButtonStatus()
    return
  end
  self:ConfirmUseYuanbao()
end
def.method().ConfirmUseYuanbao = function(self)
  if self.hasEnoughMaterial then
    self.useYuanbao = false
    self:SetButtonStatus()
    Toast(textRes.Mounts[42])
    return
  end
  CommonConfirmDlg.ShowConfirm("", textRes.Mounts[83], function(result)
    self.useYuanbao = result == 1
    self:SetButtonStatus()
  end, nil)
end
def.override().NoMounts = function(self)
  if not self.isShow then
    return
  end
  MountsPanelNodeBase.NoMounts(self)
  local Img_SX_Bg0 = self.uiObjs.Img_SX_Bg0:FindDirect("Img_SX_Bg0")
  local Group_Attribute = self.uiObjs.Img_SX_Bg0:FindDirect("Group_Attribute")
  local Group_Power = self.uiObjs.Img_SX_Bg0:FindDirect("Group_Power")
  local MountsName = Img_SX_Bg0:FindDirect("Label_JieShu")
  local Label_PowerNum = Group_Power:FindDirect("Label_PowerNum")
  local Img_Type = self.uiObjs.SX:FindDirect("Img_Type")
  local Label_RidingSpeed = self.uiObjs.SX:FindDirect("Label_RidingSpeed")
  local Label_RidingSpeedNumber = self.uiObjs.SX:FindDirect("Label_RidingSpeedNumber")
  local Btn_Promote = Group_Power:FindDirect("Btn_Promote")
  local Group_StarAttribute = self.uiObjs.Img_SX_Bg0:FindDirect("Group_StarAttribute")
  local Btn_Star = self.uiObjs.SX:FindDirect("Btn_Star")
  local Label_RidingType = self.uiObjs.SX:FindDirect("Label_RidingType")
  local Label_RidingTypeNumber = self.uiObjs.SX:FindDirect("Label_RidingTypeNumber")
  GUIUtils.SetText(MountsName, "")
  GUIUtils.SetText(Label_PowerNum, "")
  GUIUtils.SetActive(Img_Type, false)
  GUIUtils.SetActive(Label_RidingSpeed, false)
  GUIUtils.SetText(Label_RidingSpeedNumber, "")
  GUIUtils.SetActive(Btn_Promote, false)
  GUIUtils.SetActive(Label_RidingType, false)
  GUIUtils.SetText(Label_RidingTypeNumber, "")
  local lableNumInPanel = 2
  for i = 1, lableNumInPanel do
    local valueLabel = Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", i, i))
    local nameLabel = Group_Attribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", i, i))
    GUIUtils.SetActive(nameLabel, false)
    GUIUtils.SetActive(valueLabel, false)
  end
  local tabs = {
    self.uiObjs.Tap_SX,
    self.uiObjs.Tap_JN,
    self.uiObjs.Tap_SJ
  }
  for i = 1, #tabs do
    local toggleObject = tabs[i]:GetComponent("UIToggledObjects")
    toggleObject:set_enabled(false)
  end
  GUIUtils.SetActive(self.uiObjs.SX, true)
  GUIUtils.SetActive(self.uiObjs.JN, false)
  GUIUtils.SetActive(self.uiObjs.SJ, false)
  if self.modelInSX ~= nil then
    self.modelInSX:Destroy()
    self.modelInSX = nil
  end
  GUIUtils.SetActive(self.uiObjs.Btn_Switch, false)
  local lableStarNumInPanel = 5
  local attrStarIndex = 1
  for i = attrStarIndex, lableStarNumInPanel do
    local valueLabel = Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", i, i))
    local nameLabel = Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_CW_Attribute%02d", i, i))
    local Label_Active = Group_StarAttribute:FindDirect(string.format("Img_CW_BgAttribute%02d/Label_Active", i))
    GUIUtils.SetText(nameLabel, "")
    GUIUtils.SetText(valueLabel, "")
    GUIUtils.SetActive(Label_Active, false)
  end
  GUIUtils.SetActive(Btn_Star, false)
end
def.method("userdata").ShowMountsActiveSkillTips = function(self, source)
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts ~= nil then
    local mountsActiveSkillRankCfg = MountsUtils.GetMountsActiveSkillRankChange(mounts.mounts_cfg_id)
    if mountsActiveSkillRankCfg[mounts.mounts_rank] == nil then
      Toast(textRes.Mounts[35])
    elseif mountsActiveSkillRankCfg[mounts.mounts_rank].skillId == 0 then
      SkillTipMgr.Instance():ShowTipByIdEx(mountsActiveSkillRankCfg[mounts.mounts_rank + 1].skillId, source, 0)
    else
      SkillTipMgr.Instance():ShowTipByIdEx(mountsActiveSkillRankCfg[mounts.mounts_rank].skillId, source, 0)
    end
  end
end
def.method("number", "userdata").ShowMountsPassiveSkillTips = function(self, skillIdx, source)
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts ~= nil then
    local skill = mounts.passive_skill_list[skillIdx]
    if skill ~= nil then
      SkillTipMgr.Instance():ShowTipByIdEx(skill.current_passive_skill_cfg_id, source, 0)
    else
      Toast(textRes.Mounts[11])
    end
  end
end
def.method().MountsGoUp = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if MountsMgr.Instance():IsMoutsReachMaxRank(self.curMountsId) then
    Toast(textRes.Mounts[32])
  else
    local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
    if mounts ~= nil then
      local mountsNextRankCfg = MountsUtils.GetMountsCfgOfRank(mounts.mounts_cfg_id, mounts.mounts_rank + 1)
      if mountsNextRankCfg ~= nil then
        if mounts.current_score < mountsNextRankCfg.rankUpNeedScoreNum then
          self:MountsAddScore()
        else
          local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
          local heroProp = HeroPropMgr.heroProp
          if heroProp.level >= mountsNextRankCfg.needRoleLevel then
            self:MountsRankUp()
          else
            Toast(string.format(textRes.Mounts[71], mountsNextRankCfg.needRoleLevel, mountsNextRankCfg.mountsRank))
          end
        end
      end
    end
  end
end
def.method().MountsAddScore = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  require("Main.Mounts.ui.MountsJinjiePanel").Instance():ShowPanel(self.curMountsId)
end
def.method().MountsRankUp = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if self.curMountsId == nil then
    return
  end
  if self.hasEnoughMaterial or self.useYuanbao then
    local yuanBaoNum = ItemModule.Instance():GetAllYuanBao()
    if Int64.lt(yuanBaoNum, self.needYuanbao) then
      _G.GotoBuyYuanbao()
      return
    end
    MountsMgr.Instance():MountsCostItemRankUp(self.curMountsId, self.useYuanbao, self.needYuanbao)
  else
    self:ConfirmUseYuanbao()
  end
end
def.method().ResetPassiveSkill = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
  if mounts.passive_skill_list == nil or #mounts.passive_skill_list == 0 then
    Toast(textRes.Mounts[36])
  else
    require("Main.Mounts.ui.MountsSkillResetPanel").Instance():ShowPanel(self.curMountsId)
  end
end
def.method().ShowMountsStarPanel = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local mountsType = MountsMgr.Instance():GetMountsType(self.curMountsId)
  if mountsType ~= MountsTypeEnum.APPEARANCE_TYPE then
    require("Main.Mounts.ui.MountsStarPanel").Instance():ShowPanelWithMountsId(self.curMountsId)
  else
    Toast(textRes.Mounts[67])
  end
end
def.method("userdata").ShowSJMaterialTips = function(self, source)
  if self.needItemType ~= -1 then
    local needItemList = ItemUtils.GetItemTypeRefIdList(self.needItemType)
    if needItemList ~= nil then
      local needItemId = needItemList[1]
      ItemTipsMgr.Instance():ShowBasicTipsWithGO(needItemId, source.parent, 0, true)
    end
  end
end
def.override("userdata").onClickObj = function(self, clickObj)
  local id = clickObj.name
  if id == "Tap_JN" or id == "Tap_SJ" then
    if self.curMountsId == nil then
      Toast(textRes.Mounts[2])
      self.uiObjs.Tap_SX:GetComponent("UIToggle").value = true
      return
    else
      local mounts = MountsMgr.Instance():GetMountsById(self.curMountsId)
      if mounts ~= nil then
        local mountsCfg = MountsUtils.GetMountsCfgById(mounts.mounts_cfg_id)
        if mountsCfg.mountsType == MountsTypeEnum.APPEARANCE_TYPE then
          Toast(textRes.Mounts[65])
          self.uiObjs.Tap_SX:GetComponent("UIToggle").value = true
          if self.modelInSX then
            self.modelInSX:Play("Stand_c")
          end
          return
        end
      end
    end
  end
  if id == "Tap_SJ" then
    if self.modelAfterInSJ ~= nil then
      self.modelAfterInSJ:Play("Stand_c")
    end
  elseif id == "Tap_SX" then
    if self.modelInSX then
      self.modelInSX:Play("Stand_c")
    end
  elseif id == "Img_ZhudongSkill" then
    self:ShowMountsActiveSkillTips(clickObj)
  elseif string.find(id, "Img_BeidongSkill_") then
    local idx = tonumber(string.sub(id, #"Img_BeidongSkill_" + 1))
    self:ShowMountsPassiveSkillTips(idx, clickObj)
  elseif id == "Btn_SX_Tips" then
    require("GUI.GUIUtils").ShowHoverTip(constant.CMountsConsts.propertyDesTips)
  elseif id == "Btn_SJ_Tips" then
    require("GUI.GUIUtils").ShowHoverTip(constant.CMountsConsts.mountsRankUpDesTips)
  elseif id == "Btn_Jinjie" then
    self:MountsGoUp()
  elseif id == "Btn_ResetSkill" then
    self:ResetPassiveSkill()
  elseif id == "Btn_Star" then
    self:ShowMountsStarPanel()
  elseif id == "Btn_UseGold" then
    self:ClickUseYuanbao()
  elseif id == "Img_BgItem" then
    self:ShowSJMaterialTips(clickObj)
  end
end
def.override("string").onDragStart = function(self, id)
  if id == "Model_CW" then
    self.isDragSXModel = true
  elseif id == "Model_Pre" then
    self.isDragSJModelPre = true
  elseif id == "Model_After" then
    self.isDragSJModelAfter = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self.isDragSXModel = false
  self.isDragSJModelPre = false
  self.isDragSJModelAfter = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDragSXModel == true and self.modelInSX then
    self.modelInSX:SetDir(self.modelInSX.m_ang - dx / 2)
  elseif self.isDragSJModelAfter == true and self.modelAfterInSJ then
    self.modelAfterInSJ:SetDir(self.modelAfterInSJ.m_ang - dx / 2)
  end
end
def.static("table", "table").OnMountsAddScoreSuccess = function(context, params)
  local self = context
  if self ~= nil then
    self:SetMountsRankProgress()
    self:SetSJCost()
    self:SetButtonStatus()
  end
end
def.static("table", "table").OnBagInfoSynchronized = function(context, params)
  local self = context
  if self ~= nil then
    self:SetSJCost()
    self:SetButtonStatus()
  end
end
def.static("table", "table").OnMountsRankUpSuccess = function(context, params)
  local self = context
  if self ~= nil then
    self:ChooseMounts(self.curMountsId)
  end
end
BasicAttrNode.Commit()
return BasicAttrNode
