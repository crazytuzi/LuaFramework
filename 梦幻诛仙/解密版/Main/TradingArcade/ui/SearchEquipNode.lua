local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchPanelTabNodeBase = require("Main.TradingArcade.ui.SearchPanelTabNodeBase")
local SearchEquipNode = Lplus.Extend(SearchPanelTabNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SearchMgr = require("Main.TradingArcade.SearchMgr")
local SearchEquipMgr = require("Main.TradingArcade.SearchEquipMgr")
local TradingArcadeNode = require("Main.TradingArcade.ui.TradingArcadeNode")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
local SkillUtility = require("Main.Skill.SkillUtility")
local ColorType = require("consts.mzm.gsp.item.confbean.Color")
local def = SearchEquipNode.define
local instance
def.static("=>", SearchEquipNode).Instance = function(self)
  if instance == nil then
    instance = SearchEquipNode()
  end
  return instance
end
def.field("table").m_UIGOs = nil
def.field("table").m_allTypes = nil
def.field("table").m_allLevels = nil
def.field("table").m_selType = nil
def.field("table").m_selLevel = nil
def.field("table").m_selQualitys = nil
def.field("number").m_selCommonSkill = 0
def.field("number").m_selProprietarySkill = 0
def.override().OnShow = function(self)
  self:InitUI()
  self:CalcDefaultValue()
  self:UpdateUI()
  self:UpdateCustomizeNotify()
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Group_Type = self.m_node:FindDirect("Group_Type")
  self.m_UIGOs.Label_TypeName = self.m_UIGOs.Group_Type:FindDirect("Label_TypeName")
  self.m_UIGOs.Group_Level = self.m_node:FindDirect("Group_Level")
  self.m_UIGOs.Label_LevelNumber = self.m_UIGOs.Group_Level:FindDirect("Label_LevelNumber")
  self.m_UIGOs.Group_Quality = self.m_node:FindDirect("Group_Quality")
  self.m_UIGOs.Btn_Purple = self.m_UIGOs.Group_Quality:FindDirect("Btn_Purple")
  self.m_UIGOs.Btn_Orange = self.m_UIGOs.Group_Quality:FindDirect("Btn_Orange")
  self.m_UIGOs.Group_CommonEffect = self.m_node:FindDirect("Group_CommonEffect")
  self.m_UIGOs.Label_EffectName = self.m_UIGOs.Group_CommonEffect:FindDirect("Label_EffectName")
  self.m_UIGOs.Group_EquipEffect = self.m_node:FindDirect("Group_EquipEffect")
  self.m_UIGOs.Label_EquipEffectName = self.m_UIGOs.Group_EquipEffect:FindDirect("Label_EffectName")
end
def.method().UpdateUI = function(self)
  self:UpdateSelectedTypeName()
  self:UpdateSelectedLevelName()
  self:UpdateSelectedQuality()
  self:UpdateSelectedCommonEffectName()
  self:UpdateSelectedEquipEffectName()
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  if id == "Btn_ChooseType" then
    self:OnChooseTypeBtnClick()
  elseif id == "Btn_ChooseLevel" then
    self:OnChooseLevelBtnClick()
  elseif id == "Btn_ChooseCommonEffect" then
    self:OnChooseCommonEffectClick()
  elseif id == "Btn_ChooseEquipEffect" then
    self:OnChooseEquipEffectClick()
  elseif id == "Btn_Purple" then
    local isSelect = GUIUtils.IsToggle(self.m_UIGOs.Btn_Purple)
    self:SelectQuality(ColorType.PURPLE, isSelect)
  elseif id == "Btn_Orange" then
    local isSelect = GUIUtils.IsToggle(self.m_UIGOs.Btn_Orange)
    self:SelectQuality(ColorType.ORANGE, isSelect)
  end
end
def.method().OnChooseTypeBtnClick = function(self)
  local allTyps = SearchEquipMgr.Instance():GetAllEquipTypes()
  self.m_allTypes = allTyps
  self.m_bigPopupClickHandler = self.OnSelectTypeItem
  self.m_base:SetBigPopupItems(#allTyps, function(index)
    local rs = {}
    rs.name = allTyps[index].itemTypeName
    return rs
  end)
end
def.method().OnChooseLevelBtnClick = function(self)
  if self.m_selType == nil then
    Toast(textRes.TradingArcade[205])
    return
  end
  local conditions = TradingArcadeUtils.GetLevelSiftConditions(self.m_selType.subId)
  self.m_allLevels = conditions
  self.m_smallPopupClickHandler = self.OnSelectLevelItem
  self.m_base:SetSmallPopupItems(#conditions, function(index)
    local rs = {}
    rs.name = conditions[index].name
    return rs
  end)
end
def.method().OnChooseCommonEffectClick = function(self)
  if self.m_selType == nil then
    Toast(textRes.TradingArcade[205])
    return
  end
  local equipTypeKey = self.m_selType.equipTypeKey
  local strs = string.split(equipTypeKey, "_")
  local wearpos = tonumber(strs[1])
  local skillList = SearchEquipMgr.Instance():GetCommonSkillsByWearPos(wearpos)
  if #skillList == 0 then
    Toast(textRes.TradingArcade[206])
    return
  end
  table.insert(skillList, 1, 0)
  function self:m_bigPopupClickHandler(index)
    local skillId = skillList[index]
    self.m_selCommonSkill = skillId
    if skillId ~= 0 and self.m_selProprietarySkill ~= 0 then
      self.m_selProprietarySkill = 0
      Toast(textRes.TradingArcade[215])
      self:UpdateSelectedEquipEffectName()
    end
    self:UpdateSelectedCommonEffectName()
  end
  self.m_base:SetBigPopupItems(#skillList, function(index)
    local rs = {}
    local skillId = skillList[index]
    rs.name = self:GetSkillDisplayName(skillId)
    return rs
  end)
end
def.method().OnChooseEquipEffectClick = function(self)
  if self.m_selType == nil then
    Toast(textRes.TradingArcade[205])
    return
  end
  local equipTypeKey = self.m_selType.equipTypeKey
  local strs = string.split(equipTypeKey, "_")
  local wearpos = tonumber(strs[1])
  local skillList = SearchEquipMgr.Instance():GetEquipSkillsByWearPos(wearpos)
  if #skillList == 0 then
    Toast(textRes.TradingArcade[207])
    return
  end
  table.insert(skillList, 1, 0)
  function self:m_bigPopupClickHandler(index)
    local skillId = skillList[index]
    self.m_selProprietarySkill = skillId
    if skillId ~= 0 and self.m_selCommonSkill ~= 0 then
      self.m_selCommonSkill = 0
      Toast(textRes.TradingArcade[215])
      self:UpdateSelectedCommonEffectName()
    end
    self:UpdateSelectedEquipEffectName()
  end
  self.m_base:SetBigPopupItems(#skillList, function(index)
    local rs = {}
    local skillId = skillList[index]
    rs.name = self:GetSkillDisplayName(skillId)
    return rs
  end)
end
def.override().OnRestBtnClick = function(self)
  self.m_selType = nil
  self.m_selLevel = nil
  self.m_selQualitys = nil
  self.m_selCommonSkill = 0
  self.m_selProprietarySkill = 0
  self:UpdateUI()
end
def.override().OnSearchBtnClick = function(self)
  if self:CheckSelType() == false then
    return
  end
  if self:CheckSelLevel() == false then
    return
  end
  local condition = self:GetSearchCondition()
  self:InvokeSearch(SearchEquipMgr.Instance(), condition)
end
def.override().OnCustomizeBtnClick = function(self)
  if self:CheckSelType() == false then
    return
  end
  if self:CheckSelLevel() == false then
    return
  end
  if self:CheckSelSkill() == false then
    return
  end
  local condition = self:GetSearchCondition()
  CustomizedSearchMgr.Instance():CustomizeEquipReq(condition)
end
def.override().OnMyCustomizationBtnClick = function(self)
end
def.method("=>", "boolean").CheckSelType = function(self)
  if self.m_selType == nil then
    Toast(textRes.TradingArcade[205])
    return false
  end
  return true
end
def.method("=>", "boolean").CheckSelLevel = function(self)
  if self.m_selLevel == nil then
    Toast(textRes.TradingArcade[210])
    return false
  end
  return true
end
def.method("=>", "boolean").CheckSelSkill = function(self)
  if self.m_selCommonSkill == 0 and self.m_selProprietarySkill == 0 then
    Toast(textRes.TradingArcade[220])
    return false
  end
  return true
end
def.method("=>", "table").GetSearchCondition = function(self)
  local subid = self.m_selType.subId
  local level = self.m_selLevel.param
  local colors = {}
  if self.m_selQualitys and next(self.m_selQualitys) then
    for k, v in pairs(self.m_selQualitys) do
      colors[k] = k
    end
  else
    colors[ColorType.PURPLE] = ColorType.PURPLE
    colors[ColorType.ORANGE] = ColorType.ORANGE
  end
  local skillIds = {}
  if self.m_selCommonSkill ~= 0 then
    skillIds[self.m_selCommonSkill] = self.m_selCommonSkill
  end
  if self.m_selProprietarySkill ~= 0 then
    skillIds[self.m_selProprietarySkill] = self.m_selProprietarySkill
  end
  local EquipCondition = require("netio.protocol.mzm.gsp.market.EquipCondition")
  local condition = EquipCondition.new(subid, level, colors, skillIds)
  return condition
end
def.method("number").OnSelectTypeItem = function(self, index)
  self:SelectType(self.m_allTypes[index])
  self:UpdateSelectedTypeName()
  self:UpdateSelectedCommonEffectName()
  self:UpdateSelectedEquipEffectName()
end
def.method().UpdateSelectedTypeName = function(self)
  local name = ""
  if self.m_selType then
    name = self.m_selType.itemTypeName
  end
  self:SetSelectedTypeName(name)
end
def.method("number").OnSelectLevelItem = function(self, index)
  self.m_selLevel = self.m_allLevels[index]
  self:UpdateSelectedLevelName()
end
def.method().UpdateSelectedLevelName = function(self)
  local name = ""
  if self.m_selLevel then
    name = self.m_selLevel.name
  end
  self:SetSelectedLevelName(name)
end
def.method("number", "boolean").SelectQuality = function(self, quality, isSelect)
  self.m_selQualitys = self.m_selQualitys or {}
  self.m_selQualitys[quality] = isSelect and true or nil
end
def.method().UpdateSelectedQuality = function(self)
  local selectPurple = false
  local selectOrange = false
  if self.m_selQualitys then
    selectPurple = self.m_selQualitys[ColorType.PURPLE] and true or false
    selectOrange = self.m_selQualitys[ColorType.ORANGE] and true or false
  end
  GUIUtils.Toggle(self.m_UIGOs.Btn_Purple, selectPurple)
  GUIUtils.Toggle(self.m_UIGOs.Btn_Orange, selectOrange)
end
def.method().UpdateSelectedCommonEffectName = function(self)
  local name = self:GetSkillDisplayName(self.m_selCommonSkill)
  self:SetSelectedCommonEffectName(name)
end
def.method().UpdateSelectedEquipEffectName = function(self)
  local name = self:GetSkillDisplayName(self.m_selProprietarySkill)
  self:SetSelectedEquipEffectName(name)
end
def.method("number", "=>", "string").GetSkillDisplayName = function(self, skillId)
  if skillId == 0 then
    return textRes.TradingArcade[203]
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  return skillCfg.name
end
def.method("table").SelectType = function(self, type)
  if self.m_selType == nil or type == nil or self.m_selType.subId ~= type.subId then
    self.m_selType = type
    self.m_selCommonSkill = 0
    self.m_selProprietarySkill = 0
  end
end
def.method().CalcDefaultValue = function(self)
  local params = self.m_base.params
  if params.lastSubType == nil or params.lastSubType <= 1 then
    return
  end
  local defaults = SearchEquipMgr.Instance():GetDefaultValues(params.lastSubType)
  defaults.level = params.lastSiftLevel
  if defaults.type then
    self:SelectType(defaults.type)
    if defaults.level and defaults.level > 0 then
      self.m_selLevel = {
        param = defaults.level,
        name = string.format(textRes.Common[3], defaults.level)
      }
    end
  end
  params.lastSubType = nil
end
def.method("string").SetSelectedTypeName = function(self, name)
  GUIUtils.SetText(self.m_UIGOs.Label_TypeName, name)
end
def.method("string").SetSelectedLevelName = function(self, levelName)
  GUIUtils.SetText(self.m_UIGOs.Label_LevelNumber, levelName)
end
def.method("string").SetSelectedCommonEffectName = function(self, name)
  GUIUtils.SetText(self.m_UIGOs.Label_EffectName, name)
end
def.method("string").SetSelectedEquipEffectName = function(self, name)
  GUIUtils.SetText(self.m_UIGOs.Label_EquipEffectName, name)
end
return SearchEquipNode.Commit()
