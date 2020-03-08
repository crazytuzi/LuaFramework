local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SkillPanelNodeBase = require("Main.Skill.ui.SkillPanelNodeBase")
local ExerciseSkillNode = Lplus.Extend(SkillPanelNodeBase, "ExerciseSkillNode")
local SkillMgr = require("Main.Skill.SkillMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local ExerciseSkillMgr = require("Main.Skill.ExerciseSkillMgr")
local ItemModule = require("Main.Item.ItemModule")
local GUIUtils = require("GUI.GUIUtils")
local OracleMoule = require("Main.Oracle.OracleModule")
local def = ExerciseSkillNode.define
def.field("number")._selectedSkillBagIndex = 1
def.field("boolean")._isSatisfiedLevelUpNeed = false
def.field("table")._skillBagList = nil
def.field("table").uiObjs = nil
local instance
def.static("=>", ExerciseSkillNode).Instance = function()
  if instance == nil then
    instance = ExerciseSkillNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  SkillPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.EXERCISE_SKILL_UPDATE, ExerciseSkillNode.OnExerciseSkillUpdate)
  Event.RegisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ExerciseSkillNode.OnBagInfoSynchronized)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ExerciseSkillNode.OnFunctionOpenChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, ExerciseSkillNode.OnHeroLevelUp)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_GET_ORACLE_ALLOCATION, ExerciseSkillNode.OnOracleChange)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ORACLE_TOTAL_POINTS_CHANGE, ExerciseSkillNode.OnOracleChange)
  Event.RegisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_SWITCH_ORACLE_CHANGE, ExerciseSkillNode.OnOracleChange)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, ExerciseSkillNode.OnFunctionInit)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.EXERCISE_SKILL_UPDATE, ExerciseSkillNode.OnExerciseSkillUpdate)
  Event.UnregisterEvent(ModuleId.ITEM, gmodule.notifyId.item.Item_OnBagInfoSynchronized, ExerciseSkillNode.OnBagInfoSynchronized)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ExerciseSkillNode.OnFunctionOpenChange)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, ExerciseSkillNode.OnHeroLevelUp)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_GET_ORACLE_ALLOCATION, ExerciseSkillNode.OnOracleChange)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ORACLE_TOTAL_POINTS_CHANGE, ExerciseSkillNode.OnOracleChange)
  Event.UnregisterEvent(ModuleId.ORACLE, gmodule.notifyId.Oracle.ON_SWITCH_ORACLE_CHANGE, ExerciseSkillNode.OnOracleChange)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, ExerciseSkillNode.OnFunctionInit)
  self:Clear()
  SkillPanelNodeBase.OnHide(self)
end
def.override("string").onClick = function(self, id)
  if id == "Button_Tips" then
    self:OnShowTipButtonClicked()
  elseif id == "Img_Default" then
    self:OnSetDefaultButtonClicked()
  elseif id == "Button_AddExp" then
    self:OnAddExpButtonClick()
  elseif id == "Btn_Up" then
    self:OnLearnTenTimesButtonClicked()
  elseif id == "Btn_QuickUp" then
    self:OnLearnOnceButtonClicked()
  elseif string.sub(id, 1, #"item_") == "item_" then
    local index = tonumber(string.sub(id, #"item_" + 1, -1))
    self:SelectSkillBag(index)
  elseif id == "Btn_Add" then
    self:OnBuySilverButtonClick()
  end
end
def.override().InitUI = function(self)
  SkillPanelNodeBase.InitUI(self)
  local node = self.m_node
  self.uiObjs = {}
  self.uiObjs.Img_Exe_BgList = node:FindDirect("Img_Exe_BgList")
  self.uiObjs.List_Skill = self.uiObjs.Img_Exe_BgList:FindDirect("Scroll View_List/List_Skill")
  local uiList = self.uiObjs.List_Skill:GetComponent("UIList")
  uiList:set_renameControl(false)
  uiList:set_itemCount(0)
  uiList:Resize()
  self.uiObjs.Group_Discribe = node:FindDirect("Group_Discribe")
  self.uiObjs.Label_SkillName = self.uiObjs.Group_Discribe:FindDirect("Label_SkillName")
  self.uiObjs.Label_Lv = self.uiObjs.Group_Discribe:FindDirect("Label_Lv")
  self.uiObjs.Label_Discribe = self.uiObjs.Group_Discribe:FindDirect("Label_Discribe")
  self.uiObjs.Label_Effect1 = self.uiObjs.Group_Discribe:FindDirect("Label_Effect1")
  self.uiObjs.Label_Effect2 = self.uiObjs.Group_Discribe:FindDirect("Label_Effect2")
  self.uiObjs.Group_Default = self.uiObjs.Group_Discribe:FindDirect("Group_Default")
  self.uiObjs.Img_Default = self.uiObjs.Group_Default:FindDirect("Img_Default")
  self.uiObjs.Group_Slide = self.uiObjs.Group_Discribe:FindDirect("Group_Slide")
  self.uiObjs.Img_Bg = self.uiObjs.Group_Slide:FindDirect("Img_Bg")
  self.uiObjs.Label_ExpNum = self.uiObjs.Group_Slide:FindDirect("Label_ExpNum")
  self.uiObjs.Img_Red = self.uiObjs.Group_Slide:FindDirect("Button_AddExp/Img_Red")
  self.uiObjs.Group_LvUp = node:FindDirect("Group_LvUp")
  self.uiObjs.Label_UseMoneyNum = self.uiObjs.Group_LvUp:FindDirect("Img_BgUseMoney/Label_UseMoneyNum")
  self.uiObjs.Label_HaveMoneyNum = self.uiObjs.Group_LvUp:FindDirect("Img_BgHaveMoney/Label_HaveMoneyNum")
  self.uiObjs.Btn_Talent = self.uiObjs.Group_LvUp:FindDirect("Btn_Talent")
  self.uiObjs.Img_Red_Oracle = self.uiObjs.Group_LvUp:FindDirect("Btn_Talent/Img_Red")
  self.uiObjs.Label_Learn1 = self.uiObjs.Group_LvUp:FindDirect("Btn_QuickUp/Label_QuickUp")
  self.uiObjs.Label_Learn2 = self.uiObjs.Group_LvUp:FindDirect("Btn_Up/Label_Up")
end
def.override("=>", "boolean").IsUnlock = function(self)
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  local unlockLevel = require("Main.Skill.ExerciseSkillMgr").Instance():GetUnlockLevel()
  return unlockLevel <= heroProp.level
end
def.override("string").onLongPress = function(self, id)
  if string.sub(id, 1, #"item_") == "item_" then
    local index = tonumber(string.sub(id, #"item_" + 1, -1))
    self:LongPressSkillBag(index)
  end
end
def.method().UpdateUI = function(self)
  local skillBagList = ExerciseSkillMgr.Instance():GetSkillBagList()
  self._skillBagList = skillBagList
  self:SetSkillBagList(skillBagList)
  self:UpdateSelectedSkillBagInfo()
  self:_UpdateOracle()
  self:_UpdateLearnBtns()
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self._skillBagList = nil
end
def.method("table").SetSkillBagList = function(self, skillBagList)
  if skillBagList == nil then
    return
  end
  local skillBagCount = #skillBagList
  local uiList = self.uiObjs.List_Skill:GetComponent("UIList")
  uiList:set_itemCount(skillBagCount)
  uiList:Resize()
  local items = uiList.children
  for i, skillBag in ipairs(skillBagList) do
    local item = items[i]
    self:SetSkillListItem(i, item, skillBag)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("number", "userdata", "table").SetSkillListItem = function(self, index, listItem, skillBag)
  local cfgData = skillBag:GetCfgData()
  listItem:FindDirect("Label_SkillGroup"):GetComponent("UILabel"):set_text(cfgData.skillCfg.name)
  local uiTexture = listItem:FindDirect("Img_BgIconGroup/Texture_IconGroup"):GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, cfgData.skillCfg.iconId)
  local level, maxlevel = skillBag.level, skillBag:GetMaxLevel()
  listItem:FindDirect("Label_Lv"):GetComponent("UILabel"):set_text(string.format("%d/%d", level, maxlevel))
  if skillBag.isDefault then
    listItem:FindDirect("Img_MoRen"):SetActive(true)
  else
    listItem:FindDirect("Img_MoRen"):SetActive(false)
  end
end
def.method("number").SelectSkillBag = function(self, index)
  self._selectedSkillBagIndex = index
  self:UpdateSelectedSkillBagInfo()
end
def.method().UpdateSelectedSkillBagInfo = function(self)
  local skillBag = self._skillBagList[self._selectedSkillBagIndex]
  if skillBag == nil then
    return
  end
  local index = self._selectedSkillBagIndex
  self.uiObjs.List_Skill:FindDirect("item_" .. index):GetComponent("UIToggle"):set_value(true)
  self:ShowSkillBagInfo(skillBag)
  self:_UpdateLearnBtns()
end
def.method("table").ShowSkillBagInfo = function(self, skillBag)
  local cfgData = skillBag:GetCfgData()
  self.uiObjs.Label_SkillName:GetComponent("UILabel"):set_text(cfgData.skillCfg.name)
  self.uiObjs.Label_Lv:GetComponent("UILabel"):set_text(string.format(textRes.Common[3], skillBag.level))
  self.uiObjs.Label_Discribe:GetComponent("UILabel"):set_text(cfgData.skillCfg.description)
  local value = skillBag.exp / skillBag:GetLevelUpNeedExp()
  local value, maxValue = skillBag.exp, skillBag:GetLevelUpNeedExp()
  local rate = value / maxValue
  if maxValue < 0 then
    rate = 1
  end
  self.uiObjs.Img_Bg:GetComponent("UISlider"):set_sliderValue(rate)
  if maxValue >= 0 then
    self.uiObjs.Label_ExpNum:GetComponent("UILabel"):set_text(string.format("%s / %s", value, maxValue))
  else
    self.uiObjs.Label_ExpNum:GetComponent("UILabel"):set_text(textRes.Skill[17])
  end
  if skillBag.isDefault then
    self.uiObjs.Img_Default:GetComponent("UIToggle"):set_value(true)
  else
    self.uiObjs.Img_Default:GetComponent("UIToggle"):set_value(false)
  end
  self:SetSkillEffect(skillBag)
  self:UpdateLevelUpNeed()
  self:UpdateXiulianExpItemBadge()
end
def.method("table").SetSkillEffect = function(self, skillBag)
  local cfgData = skillBag:GetCfgData()
  local skillId = cfgData.skillId
  local skillEffects = SkillMgr.Instance():GetPassiveSkillEffects(skillId, skillBag.level)
  local nextSkillEffects = SkillMgr.Instance():GetPassiveSkillEffects(skillId, skillBag.level + 1)
  local effectText, effectTextNext = self:GetFormatExerciseSkillEffectsText(skillEffects, nextSkillEffects)
  self.uiObjs.Label_Effect1:GetComponent("UILabel"):set_text(effectText)
  self.uiObjs.Label_Effect2:GetComponent("UILabel"):set_text(effectTextNext)
end
def.method("table", "table", "=>", "string", "string").GetFormatExerciseSkillEffectsText = function(self, passiveSkillEffects, nextlevelEffects)
  local textTable = {}
  local nextTextTable = {}
  for k, efffect in pairs(passiveSkillEffects) do
    local cfg = GetCommonPropNameCfg(efffect.prop)
    local nextEffect = nextlevelEffects[k]
    local value = efffect.value
    local nextvalue = nextEffect.value
    local strValue = tostring(value)
    local nextStrValue = tostring(nextvalue)
    if efffect.fenmu == 10000 then
      strValue = string.format("%d%%", value / 100)
      nextStrValue = string.format("%d%%", nextvalue / 100)
    end
    if value > 0 then
      strValue = textRes.Common.Plus .. strValue
    elseif value == 0 then
      if nextvalue > 0 then
        strValue = textRes.Common.Plus .. strValue
      elseif nextvalue < 0 then
        strValue = textRes.Common.Minus .. strValue
      end
    end
    if nextvalue > 0 then
      nextStrValue = textRes.Common.Plus .. nextStrValue
    end
    local text = string.format(textRes.Skill[10], cfg.propName, strValue)
    local nextText = string.format(textRes.Skill[11], nextStrValue)
    table.insert(textTable, text)
    table.insert(nextTextTable, nextText)
  end
  return table.concat(textTable, "\n"), table.concat(nextTextTable, "\n")
end
def.method().UpdateLevelUpNeed = function(self)
  local useSilver = ExerciseSkillMgr.Instance():GetPerLevelNeedSilver()
  local haveSilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  local useSilverText = useSilver
  if Int64.lt(haveSilver, useSilver) then
    useSilverText = string.format(textRes.Common[18], useSilverText)
    self._isSatisfiedLevelUpNeed = false
  else
    self._isSatisfiedLevelUpNeed = true
  end
  self.uiObjs.Label_UseMoneyNum:GetComponent("UILabel"):set_text(useSilverText)
  self.uiObjs.Label_HaveMoneyNum:GetComponent("UILabel"):set_text(tostring(haveSilver))
end
def.method().OnSetDefaultButtonClicked = function(self)
  local skillBag = self._skillBagList[self._selectedSkillBagIndex]
  if skillBag.isDefault then
    self.uiObjs.Img_Default:GetComponent("UIToggle"):set_value(true)
    local cfgData = skillBag:GetCfgData()
    local text = string.format(textRes.Skill[19], cfgData.skillCfg.name)
    Toast(text)
    return
  end
  ExerciseSkillMgr.Instance():SetAsDefaultSkillBag(skillBag.id)
end
def.method().OnLearnOnceButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local skillBag = self._skillBagList[self._selectedSkillBagIndex]
  local studyCount = 1
  if skillBag and skillBag.level >= ExerciseSkillMgr.Instance():GetHundredOpenLevel() then
    studyCount = 10
  else
    studyCount = 1
  end
  local skillBag = self._skillBagList[self._selectedSkillBagIndex]
  local cResult = ExerciseSkillMgr.Instance():StudySkillBag(skillBag.id, studyCount)
  if cResult == ExerciseSkillMgr.CResult.ReachMaxLevel then
    Toast(textRes.Skill[14])
  elseif cResult == 30 then
    _G.GoToBuySilver(true)
  end
end
def.method().OnLearnTenTimesButtonClicked = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local skillBag = self._skillBagList[self._selectedSkillBagIndex]
  local studyCount = 10
  if skillBag and skillBag.level >= ExerciseSkillMgr.Instance():GetHundredOpenLevel() then
    studyCount = 100
  else
    studyCount = 10
  end
  local skillBag = self._skillBagList[self._selectedSkillBagIndex]
  local cResult = ExerciseSkillMgr.Instance():StudySkillBag(skillBag.id, studyCount)
  if cResult == 30 then
    Toast(textRes.Skill[14])
  elseif cResult == ExerciseSkillMgr.CResult.SilverNotEnough then
    _G.GoToBuySilver(true)
  end
end
def.static("table", "table").OnExerciseSkillUpdate = function(params)
  local skillBagId = params[1]
  local self = instance
  local index = 0
  for i, skillBag in ipairs(self._skillBagList) do
    if skillBag.id == skillBagId then
      index = i
      break
    end
  end
  local item = self.uiObjs.List_Skill:FindDirect("item_" .. index)
  local skillBag = ExerciseSkillMgr.Instance():GetSkillBag(skillBagId)
  self._skillBagList[index] = skillBag
  self:SetSkillListItem(index, item, skillBag)
  if index == self._selectedSkillBagIndex then
    self:UpdateSelectedSkillBagInfo()
  end
  self:UpdateSkillBagList()
end
def.method().UpdateSkillBagList = function(self)
  local skillBagList = self._skillBagList
  local skillBagCount = #skillBagList
  local uiList = self.uiObjs.List_Skill:GetComponent("UIList")
  uiList:set_itemCount(skillBagCount)
  uiList:Resize()
  local items = uiList.children
  for i, skillBag in ipairs(skillBagList) do
    local item = items[i]
    self:SetSkillListItem(i, item, skillBag)
  end
end
def.method("number").LongPressSkillBag = function(self, index)
  self._selectedSkillBagIndex = index
  self:UpdateSelectedSkillBagInfo()
  self:OnSetDefaultButtonClicked()
end
def.method().OnAddExpButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local skillBag = self._skillBagList[self._selectedSkillBagIndex]
  local skillBagId = skillBag.id
  local ItemUtils = require("Main.Item.ItemUtils")
  local ItemType = require("consts.mzm.gsp.item.confbean.ItemType")
  local CommonUsePanel = require("GUI.CommonUsePanel")
  local itemIdList = ItemUtils.GetNotProprietaryItemIdsByType(ItemType.XIULIAN_EXP_ITEM)
  CommonUsePanel.Instance():SetItemIdList(itemIdList)
  CommonUsePanel.Instance():ShowPanel(ExerciseSkillMgr.XiuLianExpItemFilter, nil, CommonUsePanel.Source.Other, {skillBagId = skillBagId})
end
def.method().OnShowTipButtonClicked = function(self)
  local tipId = ExerciseSkillMgr.TIP_ID
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(tipId)
  local CommonUITipsDlg = require("GUI.CommonUITipsDlg")
  CommonUITipsDlg.Instance():ShowDlg(tipContent, {x = 0, y = 0})
end
def.override("table", "table").OnSilverMoneyChanged = function(self, params, context)
  local value = params.value
  self:UpdateLevelUpNeed()
end
def.method().OnBuySilverButtonClick = function(self)
  _G.GoToBuySilver()
end
def.method().UpdateXiulianExpItemBadge = function(self)
  local skillBag = self._skillBagList[self._selectedSkillBagIndex]
  if skillBag == nil then
    return
  end
  local hasNotify = false
  if skillBag.level >= skillBag:GetMaxLevel() then
    hasNotify = false
  elseif ExerciseSkillMgr.Instance():HasXiuLianExpItem() then
    hasNotify = true
  end
  GUIUtils.SetActive(self.uiObjs.Img_Red, hasNotify)
end
def.static("table", "table").OnBagInfoSynchronized = function()
  instance:UpdateXiulianExpItemBadge()
end
def.static("table", "table").OnHeroLevelUp = function(param, context)
  ExerciseSkillNode.Instance():_UpdateOracle()
end
def.static("table", "table").OnOracleChange = function(params, context)
  ExerciseSkillNode.Instance():_UpdateOracle()
end
def.static("table", "table").OnFunctionInit = function(params, context)
  ExerciseSkillNode.OnOracleChange(params, context)
end
def.static("table", "table").OnFunctionOpenChange = function(param, context)
  local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if param.feature == ModuleFunSwitchInfo.TYPE_GENIUS then
    ExerciseSkillNode.OnOracleChange(param, context)
  end
end
def.method()._UpdateOracle = function(self)
  if OracleMoule.Instance():IsOpen(false) then
    GUIUtils.SetActive(self.uiObjs.Btn_Talent, true)
    GUIUtils.SetActive(self.uiObjs.Img_Red_Oracle, OracleMoule.Instance():NeedReddot())
  else
    GUIUtils.SetActive(self.uiObjs.Btn_Talent, false)
    GUIUtils.SetActive(self.uiObjs.Img_Red_Oracle, false)
  end
end
def.method()._UpdateLearnBtns = function(self)
  local skillBag = self._skillBagList[self._selectedSkillBagIndex]
  local btn1Text, btn2Text
  if skillBag and skillBag.level >= ExerciseSkillMgr.Instance():GetHundredOpenLevel() then
    btn1Text = textRes.Skill[121]
    btn2Text = textRes.Skill[122]
  else
    btn1Text = textRes.Skill[120]
    btn2Text = textRes.Skill[121]
  end
  GUIUtils.SetText(self.uiObjs.Label_Learn1, btn1Text)
  GUIUtils.SetText(self.uiObjs.Label_Learn2, btn2Text)
end
def.override("=>", "boolean").HasNotify = function(self)
  return OracleMoule.Instance():NeedReddot()
end
return ExerciseSkillNode.Commit()
