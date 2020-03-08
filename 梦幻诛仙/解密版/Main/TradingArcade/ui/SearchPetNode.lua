local MODULE_NAME = (...)
local Lplus = require("Lplus")
local SearchPanelTabNodeBase = require("Main.TradingArcade.ui.SearchPanelTabNodeBase")
local SearchPetNode = Lplus.Extend(SearchPanelTabNodeBase, MODULE_NAME)
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local SearchMgr = require("Main.TradingArcade.SearchMgr")
local SearchPetMgr = require("Main.TradingArcade.SearchPetMgr")
local TradingArcadeNode = require("Main.TradingArcade.ui.TradingArcadeNode")
local TradingArcadeUtils = require("Main.TradingArcade.TradingArcadeUtils")
local PetType = require("consts.mzm.gsp.pet.confbean.PetType")
local PetSkillLevelEnum = require("consts.mzm.gsp.pet.confbean.PetSkillLevelEnum")
local CustomizedSearchMgr = require("Main.TradingArcade.CustomizedSearchMgr")
local PetUtility = require("Main.Pet.PetUtility")
local def = SearchPetNode.define
local instance
def.static("=>", SearchPetNode).Instance = function(self)
  if instance == nil then
    instance = SearchPetNode()
  end
  return instance
end
local SKILL_TYPE_NONE = -1
local MIN_SKILL_NUM = 0
local MAX_SKILL_NUM = 10
def.field("table").m_UIGOs = nil
def.field("table").m_selCarryLevel = nil
def.field("table").m_selPetTypes = nil
def.field("table").m_selPet = nil
def.field("table").m_selSkills = nil
def.field("table").m_selSkillType = nil
def.field("number").m_selSkillNum = 0
def.field("table").m_pets = nil
def.override().OnShow = function(self)
  self:InitUI()
  self:CalcDefaultValue()
  self:UpdateUI()
  self:UpdateCustomizeNotify()
end
def.override().OnHide = function(self)
  self.m_UIGOs = nil
  self.m_pets = nil
end
def.method().InitUI = function(self)
  self.m_UIGOs = {}
  self.m_UIGOs.Group_HoldLevel = self.m_node:FindDirect("Group_HoldLevel")
  self.m_UIGOs.Label_Level = self.m_UIGOs.Group_HoldLevel:FindDirect("Label_Level")
  self.m_UIGOs.Group_PetName = self.m_node:FindDirect("Group_PetName")
  self.m_UIGOs.Group_PetType = self.m_node:FindDirect("Group_PetType")
  self.m_UIGOs.Btn_Baby = self.m_UIGOs.Group_PetType:FindDirect("Btn_Baby")
  self.m_UIGOs.Btn_Bianyi = self.m_UIGOs.Group_PetType:FindDirect("Btn_Bianyi")
  self.m_UIGOs.Group_Skill = self.m_node:FindDirect("Group_Skill")
  self.m_UIGOs.Label_SkillName = self.m_UIGOs.Group_Skill:FindDirect("Label_SkillName")
  self.m_UIGOs.Group_SkillType = self.m_node:FindDirect("Group_SkillType")
  self.m_UIGOs.Label_SkillTypeName = self.m_UIGOs.Group_SkillType:FindDirect("Label_SkillName")
  local Btn_ChooseSkillType = self.m_UIGOs.Group_SkillType:FindDirect("Btn_ChooseSkill")
  if Btn_ChooseSkillType then
    Btn_ChooseSkillType.name = "Btn_ChooseSkillType"
  end
  self.m_UIGOs.Group_SkillNumber = self.m_node:FindDirect("Group_SkillNumber")
  self.m_UIGOs.Label_Number = self.m_UIGOs.Group_SkillNumber:FindDirect("Label_Number")
end
def.method().UpdateUI = function(self)
  self:UpdateSelectedCarryLevel()
  self:UpdateSelectedPetType()
  self:UpdateSelectedSkillType()
  self:UpdateSelectedSkillNums({silence = false})
end
def.override("userdata").onClickObj = function(self, clickobj)
  local id = clickobj.name
  self.m_base:HidePopupPanels()
  if id == "Btn_ChooseLevel" then
    self:OnChooseLevelBtnClick()
  elseif id == "Btn_Baby" then
    local isSelect = GUIUtils.IsToggle(clickobj)
    self:SelectPetType(PetType.BAOBAO, isSelect)
  elseif id == "Btn_Bianyi" then
    local isSelect = GUIUtils.IsToggle(clickobj)
    self:SelectPetType(PetType.BIANYI, isSelect)
  elseif id == "Btn_ChooseSkill" then
    self:OnChooseSkillBtnClick()
  elseif id == "Btn_ChooseSkillType" then
    self:OnChooseSkillTypeBtnClick()
  elseif id == "Btn_Plus" then
    self.m_selSkillNum = self.m_selSkillNum + 1
    self:UpdateSelectedSkillNums({silence = false})
  elseif id == "Btn_Minus" then
    self.m_selSkillNum = self.m_selSkillNum - 1
    self:UpdateSelectedSkillNums({silence = false})
  elseif string.sub(id, 1, #"Btn_PetName") == "Btn_PetName" then
    local index = tonumber(string.sub(id, #"Btn_PetName" + 1, -1))
    if index then
      self:SelectPet(index)
    end
  elseif id == "Btn_Search" then
    self:OnSearchBtnClick()
  end
end
def.method().OnChooseLevelBtnClick = function(self)
  local carrayLevels = SearchPetMgr.Instance():GetPetCarryLevels()
  function self:m_smallPopupClickHandler(index)
    self.m_selCarryLevel = carrayLevels[index]
    self:UpdateSelectedCarryLevel()
  end
  self.m_base:SetSmallPopupItems(#carrayLevels, function(index)
    local rs = {}
    rs.name = carrayLevels[index].name
    return rs
  end)
end
def.method().OnChooseSkillTypeBtnClick = function(self)
  local skillTypes = SearchPetMgr.Instance():GetAllPetSkillType()
  local nonSkillType = {id = 0, skillLevel = -1}
  table.insert(skillTypes, 1, nonSkillType)
  function self:m_smallPopupClickHandler(index)
    local skillLevel = skillTypes[index].skillLevel
    if self.m_selSkillType == nil or self.m_selSkillType.skillLevel ~= skillLevel then
      self.m_selSkills = nil
    end
    if skillTypes[index].id > 0 then
      self.m_selSkillType = skillTypes[index]
    else
      self.m_selSkillType = nil
    end
    self:UpdateSelectedSkillType()
  end
  self.m_base:SetSmallPopupItems(#skillTypes, function(index)
    local rs = {}
    local skillType = skillTypes[index].skillLevel
    if index > 1 then
      rs.name = textRes.Pet.SkillTypeName[skillType]
    else
      rs.name = textRes.TradingArcade[203]
    end
    return rs
  end)
end
def.method().OnChooseSkillBtnClick = function(self)
  local levelId = self.m_selSkillType.id
  local skills = SearchPetMgr.Instance():GetPetSkillsByLevelId(levelId)
  function self:m_bigPopupClickHandler(index)
    self.m_selSkills = {
      skills[index]
    }
    self:UpdateSelectedSkill()
  end
  self.m_base:SetBigPopupItems(#skills, function(index)
    local rs = {}
    rs.name = skills[index].name
    return rs
  end)
end
def.method("number").SelectPet = function(self, index)
  if self.m_pets == nil then
    self.m_selPet = nil
  else
    self.m_selPet = self.m_pets[index]
  end
end
def.method("number", "boolean").SelectPetType = function(self, petType, isSelect)
  self.m_selPetTypes = self.m_selPetTypes or {}
  self.m_selPetTypes[petType] = isSelect and true or nil
end
def.method().UpdateSelectedCarryLevel = function(self)
  local text = ""
  if self.m_selCarryLevel then
    text = self.m_selCarryLevel.name
  end
  GUIUtils.SetText(self.m_UIGOs.Label_Level, text)
  self:UpdateCurCarryLevelPets()
end
def.method().UpdateCurCarryLevelPets = function(self)
  local pets = {}
  if self.m_selCarryLevel then
    local carrayLevel = self.m_selCarryLevel.param
    pets = SearchPetMgr.Instance():GetPetsByCarryLevelAndType(carrayLevel, PetType.BAOBAO)
  end
  self.m_pets = pets
  if self.m_selPet == nil or pets[1] == nil or self.m_selPet.petCfg.carryLevel ~= pets[1].petCfg.carryLevel then
    self.m_selPet = pets[1]
  end
  local MAX_PET_NUM = 3
  for i = 1, MAX_PET_NUM do
    local Btn_PetName = self.m_UIGOs.Group_PetName:FindDirect("Btn_PetName" .. i)
    self:SetPetName(Btn_PetName, pets[i])
  end
end
def.method("userdata", "table").SetPetName = function(self, Btn_PetName, data)
  local petName
  if data then
    petName = data.petCfg.templateName
  else
    petName = ""
  end
  local Label_PetName = Btn_PetName:FindDirect("Label_PetName")
  GUIUtils.SetText(Label_PetName, petName)
  if self.m_selPet and data and self.m_selPet.subId == data.subId then
    GUIUtils.Toggle(Btn_PetName, true)
  end
end
def.method().UpdateSelectedPetType = function(self)
  local selectBaoBao = false
  local selectBianYi = false
  if self.m_selPetTypes then
    selectBaoBao = self.m_selPetTypes[PetType.BAOBAO] and true or false
    selectBianYi = self.m_selPetTypes[PetType.BIANYI] and true or false
  end
  GUIUtils.Toggle(self.m_UIGOs.Btn_Baby, selectBaoBao)
  GUIUtils.Toggle(self.m_UIGOs.Btn_Bianyi, selectBianYi)
end
def.method().UpdateSelectedSkillType = function(self)
  local text = textRes.TradingArcade[203]
  if self.m_selSkillType then
    text = textRes.Pet.SkillTypeName[self.m_selSkillType.skillLevel]
  end
  GUIUtils.SetText(self.m_UIGOs.Label_SkillTypeName, text)
  if self.m_selSkillType == nil then
    GUIUtils.SetActive(self.m_UIGOs.Group_Skill, false)
  else
    GUIUtils.SetActive(self.m_UIGOs.Group_Skill, true)
    self:UpdateSelectedSkill()
  end
end
def.method().UpdateSelectedSkill = function(self)
  local text = ""
  if self.m_selSkills then
    text = self.m_selSkills[1].name
  end
  GUIUtils.SetText(self.m_UIGOs.Label_SkillName, text)
  self:UpdateSelectedSkillNums({silence = true})
end
def.method("table").UpdateSelectedSkillNums = function(self, param)
  self:ValidSkillNum(param)
  local text = self.m_selSkillNum
  GUIUtils.SetText(self.m_UIGOs.Label_Number, text)
end
def.method("table").ValidSkillNum = function(self, param)
  local silence = param.silence
  local _Toast = Toast
  local function Toast(...)
    if not silence then
      _Toast(...)
    end
  end
  local MAX_SKILL_NUM = PetUtility.Instance():GetPetConstants("PET_SHELF_SKILL_NUM_LIMIT")
  if MAX_SKILL_NUM < self.m_selSkillNum then
    self.m_selSkillNum = MAX_SKILL_NUM
    local text = string.format(textRes.TradingArcade[211], MAX_SKILL_NUM)
    Toast(text)
  else
    local min = MIN_SKILL_NUM
    if self.m_selSkills then
      min = min + #self.m_selSkills
    end
    if min > self.m_selSkillNum then
      local text = string.format(textRes.TradingArcade[212], min)
      Toast(text)
      self.m_selSkillNum = min
    end
  end
end
def.override().OnSearchBtnClick = function(self)
  if self:CheckSelCarryLevel() == false then
    return
  end
  local condition = self:GetSearchCondition()
  self:InvokeSearch(SearchPetMgr.Instance(), condition)
end
def.override().OnRestBtnClick = function(self)
  self.m_selCarryLevel = nil
  self.m_selPetTypes = nil
  self.m_selPet = nil
  self.m_selSkills = nil
  self.m_selSkillType = nil
  self.m_selSkillNum = 0
  self:UpdateUI()
end
def.override().OnCustomizeBtnClick = function(self)
  if self:CheckSelCarryLevel() == false then
    return
  end
  if self:CheckSelSkill() == false then
    return
  end
  local condition = self:GetSearchCondition()
  CustomizedSearchMgr.Instance():CustomizePetReq(condition)
end
def.method("=>", "boolean").CheckSelCarryLevel = function(self)
  if self.m_selCarryLevel == nil then
    Toast(textRes.TradingArcade[204])
    return false
  end
  return true
end
def.method("=>", "boolean").CheckSelSkill = function(self)
  local MIN_CUSTOMIZE_SKILL_NUM = _G.constant.MarketConsts.MIN_PET_CUSTOMIZED_SKILL_NUM
  if self.m_selSkills == nil and MIN_CUSTOMIZE_SKILL_NUM > self.m_selSkillNum then
    local text = string.format(textRes.TradingArcade[228], MIN_CUSTOMIZE_SKILL_NUM)
    Toast(text)
    return false
  end
  return true
end
def.method("=>", "table").GetSearchCondition = function(self)
  local subid = self.m_selPet.subId
  local petTypes = {}
  if self.m_selPetTypes and next(self.m_selPetTypes) then
    for k, v in pairs(self.m_selPetTypes) do
      petTypes[k] = k
    end
  else
    petTypes[PetType.BAOBAO] = PetType.BAOBAO
    petTypes[PetType.BIANYI] = PetType.BIANYI
  end
  local skillNum = self.m_selSkillNum
  local skillIds = {}
  if self.m_selSkills then
    for i, v in ipairs(self.m_selSkills) do
      skillIds[v.id] = v.id
    end
  end
  local qualitys = {}
  local PetCondition = require("netio.protocol.mzm.gsp.market.PetCondition")
  local condition = PetCondition.new(subid, qualitys, petTypes, skillNum, skillIds)
  return condition
end
def.method().CalcDefaultValue = function(self)
  local params = self.m_base.params
  if params.lastSubType == nil or params.lastSubType <= 1 then
    return
  end
  local defaults = SearchPetMgr.Instance():GetDefaultValues(params.lastSubType)
  if defaults.pet then
    self.m_selCarryLevel = defaults.level
    self.m_selPet = defaults.pet
  end
  params.lastSubType = nil
end
return SearchPetNode.Commit()
