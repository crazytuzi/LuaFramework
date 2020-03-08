local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchPanelTabNodeBase = require("Main.TradingArcade.ui.SearchPanelTabNodeBase")
local SearchPetEquipNode = Lplus.Extend(SearchPanelTabNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SearchMgr = require("Main.TradingArcade.SearchMgr")
local SearchPetEquipMgr = require("Main.TradingArcade.SearchPetEquipMgr")
local TradingArcadeNode = require("Main.TradingArcade.ui.TradingArcadeNode")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local SkillUtility = require("Main.Skill.SkillUtility")
local EquipModule = require("Main.Equip.EquipModule")
local PropertyType = require("consts.mzm.gsp.common.confbean.PropertyType")
local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
local def = SearchPetEquipNode.define
local instance
def.static("=>", SearchPetEquipNode).Instance = function(self)
  if instance == nil then
    instance = SearchPetEquipNode()
  end
  return instance
end
def.field("table").m_UIGOs = nil
def.field("table").m_selEquipType = nil
def.field("number").m_selProp = PropertyType.NO_PROP
def.field("number").m_selLowerSkill = 0
def.field("number").m_selAdvancedSkill = 0
def.field("table").m_skills = nil
def.field("table").m_props = nil
def.override().OnShow = function(self)
  self:InitUI()
  self:CalcDefaultValue()
  self:UpdateUI()
  self:UpdateCustomizeNotify()
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
  self.m_skills = nil
  self.m_props = nil
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Group_EquipType = self.m_node:FindDirect("Group_Type")
  if self.m_UIGOs.Group_EquipType == nil then
    self.m_UIGOs.Group_EquipType = self.m_node:FindDirect("Group_EquipType")
  else
    self.m_UIGOs.Group_EquipType.name = "Group_EquipType"
  end
  self.m_UIGOs.Label_EquipTypeName = self.m_UIGOs.Group_EquipType:FindDirect("Label_TypeName")
  self.m_UIGOs.Group_PropType = self.m_node:FindDirect("Group_Type")
  if self.m_UIGOs.Group_PropType == nil then
    self.m_UIGOs.Group_PropType = self.m_node:FindDirect("Group_PropType")
  else
    self.m_UIGOs.Group_PropType.name = "Group_PropType"
  end
  self.m_UIGOs.Group_LowSkill = self.m_node:FindDirect("Group_LowSkill")
  self.m_UIGOs.Label_LowerSkillName = self.m_UIGOs.Group_LowSkill:FindDirect("Label_SkillName")
  self.m_UIGOs.Group_AdvancedSkill = self.m_node:FindDirect("Group_AdvancedSkill")
  self.m_UIGOs.Label_AdvancedSkillName = self.m_UIGOs.Group_AdvancedSkill:FindDirect("Label_SkillName")
end
def.method().UpdateUI = function(self)
  self:UpdateSelectedEquipType()
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  print("onClickObj", id)
  if id == "Btn_ChooseType" then
    self:OnChooseEquipTypeBtnClick()
  elseif id == "Btn_ChooseLowSkill" then
    self:OnChooseLowerSkillBtnClick()
  elseif id == "Btn_ChooseAdvancedSkill" then
    self:OnChooseAdvancedSkillBtnClick()
  elseif string.sub(id, 1, #"Btn_Type") == "Btn_Type" then
    local index = tonumber(string.sub(id, #"Btn_Type" + 1, -1))
    if index then
      self:SelectProp(index)
    end
  elseif id == "Btn_Search" then
    self:OnSearchBtnClick()
  end
end
def.method().OnChooseEquipTypeBtnClick = function(self)
  local types = SearchPetEquipMgr.Instance():GetAllPetEquipmentType()
  function self:m_smallPopupClickHandler(index)
    self:SetEquipType(types[index])
    self:UpdateSelectedEquipType()
  end
  self.m_base:SetSmallPopupItems(#types, function(index)
    local rs = {}
    rs.name = types[index].name
    return rs
  end)
end
def.method().OnChooseLowerSkillBtnClick = function(self)
  if self.m_skills == nil then
    Toast(textRes.TradingArcade[200])
    return
  end
  if #self.m_skills == 0 or #self.m_skills[1] == 0 then
    Toast(textRes.TradingArcade[201])
    return
  end
  local skills = self.m_skills[1]
  function self:m_bigPopupClickHandler(index)
    local skillId = skills[index]
    if skillId ~= 0 and skillId == self.m_selAdvancedSkill then
      Toast(textRes.TradingArcade[202])
      return
    end
    self.m_selLowerSkill = skillId
    self:UpdateSelectedEquipType()
  end
  self.m_base:SetBigPopupItems(#skills, function(index)
    local rs = {}
    rs.name = self:GetSkillDisplayName(skills[index])
    return rs
  end)
end
def.method().OnChooseAdvancedSkillBtnClick = function(self)
  if self.m_skills == nil then
    Toast(textRes.TradingArcade[200])
    return
  end
  local skillLevelCount = #self.m_skills
  if #self.m_skills == 0 or #self.m_skills[skillLevelCount] == 0 then
    Toast(textRes.TradingArcade[201])
    return
  end
  local skills = self.m_skills[skillLevelCount]
  function self:m_bigPopupClickHandler(index)
    local skillId = skills[index]
    if skillId ~= 0 and skillId == self.m_selLowerSkill then
      Toast(textRes.TradingArcade[202])
      return
    end
    self.m_selAdvancedSkill = skillId
    self:UpdateSelectedEquipType()
  end
  self.m_base:SetBigPopupItems(#skills, function(index)
    local rs = {}
    rs.name = self:GetSkillDisplayName(skills[index])
    return rs
  end)
end
def.method().UpdateSelectedEquipType = function(self)
  local text = ""
  if self.m_selEquipType then
    text = self.m_selEquipType.name
  end
  GUIUtils.SetText(self.m_UIGOs.Label_EquipTypeName, text)
  self:UpdateCurPropTypes()
  self:UpdateSkillOption()
end
def.method().UpdateCurPropTypes = function(self)
  local datas = {}
  if self.m_selEquipType then
    local subId = self.m_selEquipType.id
    datas = SearchPetEquipMgr.Instance():GetEquipmentProps(subId) or {}
  end
  self.m_props = datas
  if self.m_selProp == PropertyType.NO_PROP then
    self.m_selProp = self.m_props[1] or PropertyType.NO_PROP
  end
  local MAX_NUM = 4
  for i = 1, MAX_NUM do
    local Btn_Type = self.m_UIGOs.Group_PropType:FindDirect("Btn_Type" .. i)
    self:SetEquipPropName(i, Btn_Type, datas[i])
  end
end
def.method("number", "userdata", "dynamic").SetEquipPropName = function(self, index, Btn_Type, propType)
  local name = ""
  if propType then
    name = EquipModule.GetAttriName(propType)
    GUIUtils.SetActive(Btn_Type, true)
  else
    GUIUtils.SetActive(Btn_Type, false)
    return
  end
  local Label_TypeName = Btn_Type:FindDirect("Label_TypeName" .. index)
  GUIUtils.SetText(Label_TypeName, name)
  if propType == self.m_selProp then
    GUIUtils.Toggle(Btn_Type, true)
  else
    GUIUtils.Toggle(Btn_Type, false)
  end
end
def.method().UpdateSkillOption = function(self)
  if self.m_selEquipType then
    local subId = self.m_selEquipType.id
    self.m_skills = SearchPetEquipMgr.Instance():GetEquipmentSkills(subId)
    local skillId = 0
    for i, skillIdList in ipairs(self.m_skills) do
      table.insert(skillIdList, 1, skillId)
    end
  else
    self.m_skills = nil
  end
  local lowerSkillName = textRes.TradingArcade[203]
  local advancedSkillName = textRes.TradingArcade[203]
  if 0 < self.m_selLowerSkill then
    lowerSkillName = self:GetSkillDisplayName(self.m_selLowerSkill)
  end
  if 0 < self.m_selAdvancedSkill then
    advancedSkillName = self:GetSkillDisplayName(self.m_selAdvancedSkill)
  end
  GUIUtils.SetText(self.m_UIGOs.Label_LowerSkillName, lowerSkillName)
  GUIUtils.SetText(self.m_UIGOs.Label_AdvancedSkillName, advancedSkillName)
  if self.m_skills and #self.m_skills > 0 then
    local Label_SkillTypeName = self.m_UIGOs.Group_LowSkill:FindDirect("Label_Skill")
    local skillType = 0
    if 0 < #self.m_skills[1] then
      skillType = self.m_skills[1].skillLevel
    end
    local skillTypeName = textRes.Pet.SkillTypeName[skillType] or ""
    GUIUtils.SetText(Label_SkillTypeName, skillTypeName)
    local Label_SkillTypeName = self.m_UIGOs.Group_AdvancedSkill:FindDirect("Label_Skill")
    local skillType = 0
    if #self.m_skills[#self.m_skills] > 0 then
      skillType = self.m_skills[#self.m_skills].skillLevel
    end
    local skillTypeName = textRes.Pet.SkillTypeName[skillType] or ""
    GUIUtils.SetText(Label_SkillTypeName, skillTypeName)
  end
end
def.method("number").SelectProp = function(self, index)
  local prop = self.m_props[index]
  self.m_selProp = prop
end
def.override().OnSearchBtnClick = function(self)
  if self:CheckSelEquipType() == false then
    return
  end
  if self:CheckSelSkill() == false then
    return
  end
  local subid = self.m_selEquipType.id
  local property = self.m_selProp
  local skillIds = {}
  if self.m_selLowerSkill ~= 0 then
    skillIds[self.m_selLowerSkill] = self.m_selLowerSkill
    warn("self.m_selLowerSkill", self.m_selLowerSkill)
  end
  if self.m_selAdvancedSkill ~= 0 then
    skillIds[self.m_selAdvancedSkill] = self.m_selAdvancedSkill
    warn("self.m_selAdvancedSkill", self.m_selAdvancedSkill)
  end
  local PetEquipCondition = require("netio.protocol.mzm.gsp.market.PetEquipCondition")
  local condition = PetEquipCondition.new(subid, property, skillIds)
  self:InvokeSearch(SearchPetEquipMgr.Instance(), condition)
end
def.override().OnRestBtnClick = function(self)
  self.m_selEquipType = nil
  self.m_selProp = PropertyType.NO_PROP
  self.m_selLowerSkill = 0
  self.m_selAdvancedSkill = 0
  self:UpdateUI()
end
def.override().OnCustomizeBtnClick = function(self)
  if self:CheckSelEquipType() == false then
    return
  end
  if self:CheckAmuletEquip() == false then
    return
  end
  if self:CheckSelSkill() == false then
    return
  end
  local condition = self:GetSearchCondition()
  CustomizedSearchMgr.Instance():CustomizePetEquipReq(condition)
end
def.method("=>", "boolean").CheckSelEquipType = function(self)
  if self.m_selEquipType == nil then
    Toast(textRes.TradingArcade[200])
    return false
  end
  return true
end
def.method("=>", "boolean").CheckAmuletEquip = function(self)
  if self.m_skills == nil or #self.m_skills == 0 then
    Toast(textRes.TradingArcade[229])
    return false
  end
  return true
end
def.method("=>", "boolean").CheckSelSkill = function(self)
  if self.m_skills and #self.m_skills > 0 and self.m_selLowerSkill == 0 and self.m_selAdvancedSkill == 0 then
    Toast(textRes.TradingArcade[214])
    return false
  end
  return true
end
def.method("=>", "table").GetSearchCondition = function(self)
  local subid = self.m_selEquipType.id
  local property = self.m_selProp
  local skillIds = {}
  if self.m_selLowerSkill ~= 0 then
    skillIds[self.m_selLowerSkill] = self.m_selLowerSkill
    warn("self.m_selLowerSkill", self.m_selLowerSkill)
  end
  if self.m_selAdvancedSkill ~= 0 then
    skillIds[self.m_selAdvancedSkill] = self.m_selAdvancedSkill
    warn("self.m_selAdvancedSkill", self.m_selAdvancedSkill)
  end
  local PetEquipCondition = require("netio.protocol.mzm.gsp.market.PetEquipCondition")
  local condition = PetEquipCondition.new(subid, property, skillIds)
  return condition
end
def.method("number", "=>", "string").GetSkillDisplayName = function(self, skillId)
  if skillId == 0 then
    return textRes.TradingArcade[203]
  end
  local skillCfg = SkillUtility.GetSkillCfg(skillId)
  return skillCfg.name
end
def.method("table").SetEquipType = function(self, equipType)
  if self.m_selEquipType == nil or equipType == nil or self.m_selEquipType.id ~= equipType.id then
    self.m_selEquipType = equipType
    self.m_selProp = PropertyType.NO_PROP
    self.m_selLowerSkill = 0
    self.m_selAdvancedSkill = 0
  end
end
def.method().CalcDefaultValue = function(self)
  local params = self.m_base.params
  if params.lastSubType == nil or params.lastSubType <= 1 then
    return
  end
  local defaults = SearchPetEquipMgr.Instance():GetDefaultValues(params.lastSubType)
  if defaults.type then
    self:SetEquipType(defaults.type)
  end
  params.lastSubType = nil
end
return SearchPetEquipNode.Commit()
