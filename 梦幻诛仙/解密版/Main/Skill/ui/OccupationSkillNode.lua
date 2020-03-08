local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local SkillPanelNodeBase = require("Main.Skill.ui.SkillPanelNodeBase")
local OccupationSkillNode = Lplus.Extend(SkillPanelNodeBase, "OccupationSkillNode")
local SkillMgr = require("Main.Skill.SkillMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local def = OccupationSkillNode.define
local GUIUtils = require("GUI.GUIUtils")
def.const("number").MAX_SKILL_NUM_PER_BAG = 4
def.field("number")._selectedSkillBagIndex = 1
def.field("boolean")._isSatisfiedLevelUpNeed = false
def.field("number")._enchantingSkillIndex = 0
def.field("number")._enchantingSkillId = 0
def.field("userdata").ui_List_Skill = nil
def.field("userdata").ui_Label_TitleDiscribe = nil
def.field("userdata").ui_Label_Discribe = nil
def.field("userdata").ui_Label_Effect = nil
def.field("userdata").ui_List_SkillIcon = nil
def.field("userdata").UI_JieSuoXinJiNeng = nil
local instance
def.static("=>", OccupationSkillNode).Instance = function()
  if instance == nil then
    instance = OccupationSkillNode()
  end
  return instance
end
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  SkillPanelNodeBase.Init(self, base, node)
  self:InitUI()
end
def.override().OnShow = function(self)
  self:UpdateUI()
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_BAG_LEVEL_UP_SUCCESS, OccupationSkillNode.OnOccupationSkillBagLevelUpSuccess)
  Event.RegisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_UNLOCK, OccupationSkillNode.OnOccupationSkillUnlock)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, OccupationSkillNode.OnHeroLevelUp)
end
def.override().OnHide = function(self)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_BAG_LEVEL_UP_SUCCESS, OccupationSkillNode.OnOccupationSkillBagLevelUpSuccess)
  Event.UnregisterEvent(ModuleId.SKILL, gmodule.notifyId.Skill.OCCUPATION_SKILL_UNLOCK, OccupationSkillNode.OnOccupationSkillUnlock)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, OccupationSkillNode.OnHeroLevelUp)
  SkillPanelNodeBase.OnHide(self)
end
def.override("string").onClick = function(self, id)
  if id == "Btn_Up" then
    self:OnLevelUpButtonClick()
  elseif id == "Btn_QuickUp" then
    self:OnAutoLevelUpButtonClick()
  elseif id == "Btn_Add" then
    self:OnBuySilverButtonClick()
  elseif string.sub(id, 1, #"Img_BgSkillGroup_") == "Img_BgSkillGroup_" then
    local index = tonumber(string.sub(id, #"Img_BgSkillGroup_" + 1, -1))
    self:OnSkillBagSelected(index)
  elseif string.sub(id, 1, 11) == "Img_BgIcon_" then
    local index = tonumber(string.sub(id, 12, -1))
    self:OnSkillSelected(index)
  end
end
def.override().InitUI = function(self)
  SkillPanelNodeBase.InitUI(self)
  local node = self.m_node
  self.ui_List_Skill = node:FindDirect("Img_BgList/Scroll View_List/List_Skill")
  local ui_Group_Discribe = node:FindDirect("Group_Discribe")
  self.ui_Label_TitleDiscribe = ui_Group_Discribe:FindDirect("Label_TitleDiscribe")
  self.ui_Label_Discribe = ui_Group_Discribe:FindDirect("Label_Discribe")
  self.ui_Label_Effect = ui_Group_Discribe:FindDirect("Label_Effect")
  self.ui_List_SkillIcon = node:FindDirect("Group_Skill/Group_SkillIcon")
  self.UI_JieSuoXinJiNeng = self.m_panel:FindDirect("Img_Bg0/UI_JieSuoXinJiNeng")
end
def.override("=>", "boolean").IsUnlock = function(self)
  return true
end
def.override("=>", "boolean").HasNotify = function(self)
  return SkillMgr.Instance():HasEnchantingSkillNotify() or self:IsSkillFuncJustUnlock()
end
def.method("number").OnSkillBagSelected = function(self, index)
  self._selectedSkillBagIndex = index
  self:UpdateSelectedSkillBag()
end
def.method("number").OnSkillSelected = function(self, index)
  if self._enchantingSkillIndex == index then
    self:OnEnchantingSkillSelected(index)
    return
  end
  local CommonSkillTip = require("GUI.CommonSkillTip")
  local skillBagList = SkillMgr.Instance():GetOccupationSkillBagList()
  local skillBag = skillBagList[self._selectedSkillBagIndex]
  if skillBag == nil then
    return
  end
  local skillDataList = skillBag:GetActiveSkillList()
  local skillData = skillDataList[index]
  if skillData then
    local sourceObj = self.ui_List_SkillIcon:FindDirect(string.format("item_%d/Img_BgIcon_%d", index, index))
    self:ShowSkillTip(sourceObj, skillData)
    SkillMgr.Instance():MarkUnlockState(skillData.bagId, skillData.id, false)
    GUIUtils.SetActive(sourceObj.parent:FindDirect("Img_Red"), false)
    local index = self._selectedSkillBagIndex
    local itemObj = self.ui_List_Skill:FindDirect(string.format("Img_BgSkillGroup_%d", index))
    self:SetSkillBagState(itemObj, index, skillBag)
  else
    Toast(textRes.Skill[18])
  end
end
def.method("number").OnEnchantingSkillSelected = function(self, index)
  local skillData = SkillMgr.Instance():GetEnchantingSkill()
  local CommonSkillTip = require("GUI.CommonSkillTip")
  if skillData then
    if skillData:IsUnlock() then
      self:SwitchToSkillEnchanting()
      SkillMgr.Instance():SetEnchantingSkillNotify(false)
    else
      local sourceObj = self.ui_List_SkillIcon:FindDirect(string.format("item_%d/Img_BgIcon_%d", index, index))
      self:ShowSkillTip(sourceObj, skillData)
    end
  else
    warn("attemp to index a nil skill", index)
  end
end
def.method().UpdateUI = function(self)
  local skillBagList = SkillMgr.Instance():GetOccupationSkillBagList()
  self:SetSkillBagList(skillBagList)
  self:UpdateSelectedSkillBag()
end
def.method().UpdateSelectedSkillBag = function(self)
  local skillBagList = SkillMgr.Instance():GetOccupationSkillBagList()
  local skillBag = skillBagList[self._selectedSkillBagIndex]
  if skillBag then
    local skillBagCfg = skillBag:GetCfgData()
    self:SetSkillBagName(skillBagCfg.name)
    self:SetSkillBagDesc(skillBagCfg.description)
    self:SetSkillList(skillBag)
    self:SetLevelUpNeed(skillBag)
    local passiveSkill = skillBag:GetPassiveSkill()
    local passiveSkillText = ""
    if passiveSkill then
      local skillEffects = SkillMgr.Instance():GetPassiveSkillEffects(passiveSkill.id, passiveSkill.level)
      local nextSkillEffects = SkillMgr.Instance():GetPassiveSkillEffects(passiveSkill.id, passiveSkill.level + 1)
      passiveSkillText = self:GetFormatPassiveSkillEffectsText(skillEffects, nextSkillEffects)
    else
      passiveSkillText = skillBagCfg.propText
    end
    self:SetSkillBagEffect(passiveSkillText)
  end
end
def.method("table", "table", "=>", "string").GetFormatPassiveSkillEffectsText = function(self, passiveSkillEffects, nextlevelEffects)
  local textTable = {}
  for k, efffect in pairs(passiveSkillEffects) do
    local cfg = GetCommonPropNameCfg(efffect.prop)
    local nextEffect = nextlevelEffects[k]
    local value = efffect.value
    local nextvalue = nextEffect.value
    local strValue = tostring(value)
    local nextStrValue = tostring(nextvalue)
    if efffect.fenmu == 10000 then
      value = string.format("%d%%", value / 100)
      nextvalue = string.format("%d%%", nextvalue / 100)
    end
    if value > 0 then
      strValue = textRes.Common.Plus .. strValue
    elseif value == 0 then
      if nextvalue >= 0 then
        strValue = textRes.Common.Plus .. strValue
      elseif nextvalue < 0 then
        strValue = textRes.Common.Minus .. strValue
      end
    end
    if nextvalue > 0 then
      nextStrValue = textRes.Common.Plus .. nextStrValue
    end
    local text = string.format(textRes.Skill[10], cfg.propName, strValue)
    table.insert(textTable, text)
  end
  return table.concat(textTable, [[


]])
end
def.method("table").SetSkillBagList = function(self, skillBagList)
  local uiList = self.ui_List_Skill:GetComponent("UIList")
  local skillBagAmount = #skillBagList
  local skillBagMaxLevel = SkillMgr.Instance():GetSkillBagMaxLevel()
  uiList:set_itemCount(skillBagAmount)
  uiList:Resize()
  local items = uiList:get_children()
  for i = 1, skillBagAmount do
    local item = items[i]
    local skillBag = skillBagList[i]
    self:SetSkillBagListItemInfo(item, i, skillBag, skillBagMaxLevel)
    local uiToggle = item:GetComponent("UIToggle")
    if self._selectedSkillBagIndex == i then
      uiToggle:set_value(true)
    else
      uiToggle:set_value(false)
    end
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("userdata", "number", "table", "number").SetSkillBagListItemInfo = function(self, item, index, skillBag, maxLevel)
  local skillBagCfg = skillBag:GetCfgData()
  local ui_Label_SkillGroup = item:FindDirect(string.format("Label_SkillGroup_%d", index))
  ui_Label_SkillGroup:GetComponent("UILabel"):set_text(skillBagCfg.name)
  local levelInfo = string.format("%d/%d", skillBag.level, maxLevel)
  local ui_Label_Lv = item:FindDirect(string.format("Label_Lv_%d", index))
  ui_Label_Lv:GetComponent("UILabel"):set_text(levelInfo)
  local ui_Texture_IconGroup = item:FindDirect(string.format("Img_BgIconGroup_%d/Texture_IconGroup_%d", index, index))
  local uiTexture = ui_Texture_IconGroup:GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, skillBagCfg.iconId)
  self:SetSkillBagState(item, index, skillBag)
end
def.method("userdata", "number", "table").SetSkillBagState = function(self, itemObj, index, skillBag)
  local hasNotify = false
  local enchantingSkill = SkillMgr.Instance():GetEnchantingSkill()
  if enchantingSkill.bagId == skillBag.id then
    hasNotify = SkillMgr.Instance():HasEnchantingSkillNotify()
  elseif SkillMgr.Instance():HasJustUnlockedSkill(skillBag.id) then
    hasNotify = true
  end
  GUIUtils.SetActive(itemObj:FindDirect("Img_Red_" .. index), hasNotify)
end
def.method("string").SetSkillBagName = function(self, name)
  self.ui_Label_TitleDiscribe:GetComponent("UILabel"):set_text(name)
end
def.method("string").SetSkillBagDesc = function(self, description)
  self.ui_Label_Discribe:GetComponent("UILabel"):set_text(description)
end
def.method("string").SetSkillBagEffect = function(self, effect)
  self.ui_Label_Effect:GetComponent("UILabel"):set_text(effect)
end
def.method("table").SetSkillList = function(self, skillBag)
  local skillBagCfg = skillBag:GetCfgData()
  local activeSkillList = skillBag:GetActiveSkillList()
  local skillAmount = OccupationSkillNode.MAX_SKILL_NUM_PER_BAG
  self._enchantingSkillIndex = 0
  for i = 1, skillAmount do
    local item = self.ui_List_SkillIcon:FindDirect("item_" .. i)
    local skill = activeSkillList[i]
    self:SetSkillListItemInfo(item, i, skill, skillBag.level)
  end
  self.m_base:TouchGameObject(self.m_base.m_panel, self.m_base.m_parent)
end
def.method("userdata", "number", "table", "number").SetSkillListItemInfo = function(self, item, index, skill, skillBagLevel)
  if skill == nil then
    self:SetEmptySkillListItem(item, index)
    return
  end
  local Img_Red = item:FindDirect("Img_Red")
  local hasNotify = false
  local skillCfg
  if skill:IsEnchantingSkill() then
    self._enchantingSkillIndex = index
    self._enchantingSkillId = skill.id
    skillCfg = SkillUtility.GetEnchantingSkillCfg(skill.id)
    hasNotify = SkillMgr.Instance():HasEnchantingSkillNotify()
  else
    skillCfg = SkillUtility.GetSkillCfg(skill.id)
    hasNotify = SkillMgr.Instance():IsJustUnlockedSkill(skill.bagId, skill.id)
  end
  GUIUtils.SetActive(Img_Red, hasNotify)
  GUIUtils.SetActive(item, true)
  local ui_Label_SkillGroup = item:FindDirect("Label_SkillName")
  ui_Label_SkillGroup:GetComponent("UILabel"):set_text(skillCfg.name)
  local ui_Img_BgIcon = item:FindDirect("Img_BgIcon")
  if ui_Img_BgIcon then
    ui_Img_BgIcon.name = "Img_BgIcon_" .. index
  else
    ui_Img_BgIcon = item:FindDirect("Img_BgIcon_" .. index)
  end
  local ui_Texture_IconGroup = ui_Img_BgIcon:FindDirect("Texture_Icon")
  local uiTexture = ui_Texture_IconGroup:GetComponent("UITexture")
  require("GUI.GUIUtils").FillIcon(uiTexture, skillCfg.iconId)
  local ui_Img_Lock = ui_Img_BgIcon:FindDirect("Img_Lock")
  if skillBagLevel >= skill.unlockLevel then
    ui_Img_Lock:SetActive(false)
    uiTexture:set_color(Color.Color(1, 1, 1, 1))
  else
    ui_Img_Lock:SetActive(true)
    uiTexture:set_color(Color.Color(0.737, 0.737, 0.737, 1))
  end
end
def.method("userdata", "number").SetEmptySkillListItem = function(self, item, index)
  GUIUtils.SetActive(item, false)
end
def.method().UpdateSkillListState = function(self)
end
def.method("table").SetLevelUpNeed = function(self, skillBag)
  local skillBagCfg = skillBag:GetCfgData()
  local ui_Group_LvUp = self.m_node:FindDirect("Group_LvUp")
  local levelUpNeedCfg = SkillUtility.GetOccupationSkillBagLevelUpNeedCfg(skillBag.level, skillBagCfg.levelUpCfgId)
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  local ui_Label_UseMoneyNum = ui_Group_LvUp:FindDirect("Img_BgUseMoney/Label_UseMoneyNum")
  local ui_Label_HaveMoneyNum = ui_Group_LvUp:FindDirect("Img_BgHaveMoney/Label_HaveMoneyNum")
  local moneySilverText = tostring(moneySilver)
  local needSilverText = levelUpNeedCfg.needSilver
  if moneySilver:ge(levelUpNeedCfg.needSilver) then
    self._isSatisfiedLevelUpNeed = true
  else
    self._isSatisfiedLevelUpNeed = false
    needSilverText = string.format(textRes.Common[18], needSilverText)
  end
  ui_Label_UseMoneyNum:GetComponent("UILabel"):set_text(needSilverText)
  ui_Label_HaveMoneyNum:GetComponent("UILabel"):set_text(moneySilverText)
end
def.method("userdata", "table").ShowSkillTip = function(self, sourceObj, skillData)
  local position = sourceObj:get_position()
  local screenPos = WorldPosToScreen(position.x, position.y)
  local widget = sourceObj:GetComponent("UIWidget")
  require("Main.Skill.SkillTipMgr").Instance():ShowTip(skillData, screenPos.x, screenPos.y, widget:get_width(), widget:get_height(), -1)
end
def.method().OnLevelUpButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local skillBagList = SkillMgr.Instance():GetOccupationSkillBagList()
  local skillBag = skillBagList[self._selectedSkillBagIndex]
  if nil == skillBag then
    return
  end
  if self._selectedSkillBagIndex ~= 1 and skillBagList[1].level <= skillBag.level then
    local mainCfg = skillBagList[1]:GetCfgData()
    local curCfg = skillBag:GetCfgData()
    local text = string.format(textRes.Skill[1], curCfg.name, mainCfg.name)
    Toast(text)
  elseif SkillMgr.Instance():IsOccupationSkillBagMaxLevel(skillBag) then
    Toast(textRes.Skill[2])
  elseif not self._isSatisfiedLevelUpNeed then
    _G.GoToBuySilver(true)
  else
    SkillMgr.Instance():LevelUpOccupationSkillBag(skillBag.id)
  end
end
def.method().OnAutoLevelUpButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local skillBagList = SkillMgr.Instance():GetOccupationSkillBagList()
  local skillBag = skillBagList[self._selectedSkillBagIndex]
  if nil == skillBag then
    return
  end
  if SkillMgr.Instance():IsAllOccupationSkillBagMaxLevel() then
    Toast(textRes.Skill[2])
  else
    if not SkillMgr.Instance():HaveSilverToLevelUpSkillBag() then
      _G.GoToBuySilver(true)
      return
    end
    local consumeSilver = SkillMgr.Instance():GetLevelAllSkillBagMaxNeed()
    if SkillMgr.Instance():IsNeedAutoLevelConfirm(consumeSilver) then
      self:ShowAutoLevelConfirm(consumeSilver)
    else
      SkillMgr.Instance():AutoLevelUpOccupationSkillBag()
    end
  end
end
def.method("userdata").ShowAutoLevelConfirm = function(self, consumeSilver)
  local coloredSilverText = tostring(consumeSilver)
  local ItemModule = require("Main.Item.ItemModule")
  local moneySilver = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER) or Int64.new(0)
  if consumeSilver > moneySilver then
    local consumeSilver = SkillMgr.Instance():GetAutoLevelUpSkillBagConsume().silver
    coloredSilverText = string.format("[ff0000]%s[-]", tostring(consumeSilver))
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowConfirm(textRes.Skill[24], string.format(textRes.Skill[25], coloredSilverText), function(s)
    if s == 1 then
      SkillMgr.Instance():AutoLevelUpOccupationSkillBag()
    end
  end, nil)
end
def.method().OnBuySilverButtonClick = function(self)
  _G.GoToBuySilver()
end
def.static("table", "table").OnOccupationSkillBagLevelUpSuccess = function(params, context)
  local skillBagId = params[1]
  local useSilver = params[2]
  local self = instance
  self:UpdateUI()
  local skillBag = SkillMgr.Instance():GetOccupationSkillBag(skillBagId)
  local skillBagCfg = skillBag:GetCfgData()
  local ItemModule = require("Main.Item.ItemModule")
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  local text = string.format(textRes.Skill[5], skillBagCfg.name, skillBag.level)
  PersonalHelper.CommonTableMsg({
    {
      PersonalHelper.Type.Text,
      text
    }
  })
end
def.override("table", "table").OnSilverMoneyChanged = function(self, params, context)
  local value = params.value
  self:UpdateLevelUpNeed()
end
def.method().UpdateLevelUpNeed = function(self)
  local skillBagList = SkillMgr.Instance():GetOccupationSkillBagList()
  local skillBag = skillBagList[self._selectedSkillBagIndex]
  if skillBag then
    self:SetLevelUpNeed(skillBag)
  end
end
def.method().SwitchToSkillEnchanting = function(self)
  Event.DispatchEvent(ModuleId.SKILL, gmodule.notifyId.Skill.SELECT_ENCHANTING_SKILL, {
    self._enchantingSkillId
  })
end
local timerId = 0
def.static("table", "table").OnOccupationSkillUnlock = function(params, context)
  local skillBagId = params[1]
  local skillId = params[2]
  local skillBag = SkillMgr.Instance():GetOccupationSkillBag(skillBagId)
  local skillBagCfg = skillBag:GetCfgData()
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  local skillBagName = skillBagCfg.name
  local skillName = skillCfg.name
  local text = string.format(textRes.Skill[15], skillBagName, skillName)
  local PersonalHelper = require("Main.Chat.PersonalHelper")
  PersonalHelper.CommonTableMsg({
    {
      PersonalHelper.Type.Text,
      text
    }
  })
  GUIUtils.SetActive(instance.UI_JieSuoXinJiNeng, false)
  GUIUtils.SetActive(instance.UI_JieSuoXinJiNeng, true)
  local self = instance
  if timerId == 0 then
    timerId = GameUtil.AddGlobalTimer(0, true, function(...)
      if self.m_panel == nil or self.m_panel.isnil then
        return
      end
      timerId = 0
      self:UpdateUI()
    end)
  end
end
def.static("table", "table").OnHeroLevelUp = function(params, context)
  instance:UpdateUI()
end
def.override().OnSkillNotifyUpdate = function(self)
  instance:UpdateUI()
end
return OccupationSkillNode.Commit()
