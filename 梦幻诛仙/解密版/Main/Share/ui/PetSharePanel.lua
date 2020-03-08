local Lplus = require("Lplus")
local BaseSharePanel = require("Main.Share.ui.BaseSharePanel")
local PetSharePanel = Lplus.Extend(BaseSharePanel, "PetSharePanel")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetMgrInstance = PetMgr.Instance()
local PetUtility = require("Main.Pet.PetUtility")
local PetData = Lplus.ForwardDeclare("PetData")
local ItemUtils = require("Main.Item.ItemUtils")
local GUIUtils = require("GUI.GUIUtils")
local ECUIModel = require("Model.ECUIModel")
local def = PetSharePanel.define
local instance
def.field("table")._uiObjs = nil
def.field("table")._model = nil
def.field("userdata")._petId = nil
def.field("table")._petData = nil
def.static("=>", PetSharePanel).Instance = function()
  if instance == nil then
    instance = PetSharePanel()
    instance.m_depthLayer = GUIDEPTH.TOPMOST2
  end
  return instance
end
def.method("userdata").ShowSharePanel = function(self, petId)
  if self.m_panel == nil then
    self._petId = petId
    self:CreatePanel(RESPATH.PREFEB_PET_SHARE_PANEL, 1)
    self:SetModal(true)
  end
end
def.override().OnCreate = function(self)
  BaseSharePanel.OnCreate(self)
  self:_LoadPetData()
  self:_InitUI()
  self:_SetPetBasicInfo()
  self:_SetPetGrowInfo()
  self:_SetPetSkills()
  self:_SetPetModel()
  self:_SetEquipment()
end
def.method()._LoadPetData = function(self)
  self._petData = PetMgrInstance:GetPet(self._petId)
end
def.method()._InitUI = function(self)
  self._uiObjs = {}
  self._uiObjs.Img_BgPower = self.m_panel:FindDirect("Img_BgPower")
  self._uiObjs.Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self._uiObjs.Img_Skill = self.m_panel:FindDirect("Img_Skill")
  self._uiObjs.Img_Logo = self.m_panel:FindDirect("Img_Logo")
  self._uiObjs.Img_Bg0:FindDirect("Btn_Close"):SetActive(false)
  self._uiObjs.Img_Logo:SetActive(false)
end
def.method()._SetPetBasicInfo = function(self)
  local petName = self._uiObjs.Img_Bg0:FindDirect("Img_BgPetName/Label_PetName")
  local petLevel = self._uiObjs.Img_Bg0:FindDirect("Img_BgPetName/Label_Lv")
  local petYaoli = self._uiObjs.Img_BgPower:FindDirect("Label_PowerNum")
  local petScore = self._uiObjs.Img_BgPower:FindDirect("Label_PowerLv")
  local petType = self._uiObjs.Img_Bg0:FindDirect("Img_BgImage0/Img_PetType")
  petName:GetComponent("UILabel").text = self._petData.name
  petLevel:GetComponent("UILabel").text = string.format(textRes.Share[2], self._petData.level)
  petYaoli:GetComponent("UILabel").text = self._petData:GetYaoLi()
  petScore:GetComponent("UILabel").text = self._petData:GetPetYaoLiCfg().encodeChar
  petType:GetComponent("UISprite").spriteName = PetUtility.GetPetTypeSpriteName(self._petData:GetPetCfgData().type)
  local petCfgData = self._petData:GetPetCfgData()
  local Img_BgImage0 = self._uiObjs.Img_Bg0:FindDirect("Img_BgImage0")
  if petCfgData.isSpecial then
    Img_BgImage0:FindDirect("Img_Zhuan"):SetActive(true)
    Img_BgImage0:FindDirect("Img_Bang"):SetActive(false)
  elseif self._petData.isBinded then
    Img_BgImage0:FindDirect("Img_Zhuan"):SetActive(false)
    Img_BgImage0:FindDirect("Img_Bang"):SetActive(true)
  else
    Img_BgImage0:FindDirect("Img_Zhuan"):SetActive(false)
    Img_BgImage0:FindDirect("Img_Bang"):SetActive(false)
  end
  local carrayLevel = petCfgData.carryLevel
  local Label_Lv = Img_BgImage0:FindDirect("Label_Lv")
  Label_Lv:GetComponent("UILabel").text = string.format(textRes.Pet[107], carrayLevel)
  local secondProp = self._petData.secondProp
  local props = {
    self._petData.hp,
    self._petData.mp,
    secondProp.phyAtk,
    secondProp.magAtk,
    secondProp.phyDef,
    secondProp.magDef,
    secondProp.speed
  }
  for i = 1, #props do
    local propLabel = self._uiObjs.Img_Bg0:FindDirect(string.format("Img_CW_BgBasic/Img_CW_BgAttribute%02d/Label_CW_AttributeNum%02d", i, i))
    propLabel:GetComponent("UILabel").text = props[i]
  end
  if self._petData:CanJinjie() then
    self:_SetPetStageLevel(self._petData.stageLevel)
  else
    self:_ClearPetStageLevel()
  end
  local Img_Tpye = self.m_panel:FindDirect("Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(petCfgData.changeModelCardClassType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.method()._SetPetGrowInfo = function(self)
  local viewData = PetUtility.GetPetGrowValueViewData(self._petData)
  local growDesc = string.format("[%s]%s(%s)[-]", viewData.color, viewData.value, viewData.meaning)
  local growLabel = self._uiObjs.Img_Bg0:FindDirect("Img_CW_BgAttribute/Img_BgGrown/Label_GrownNum")
  growLabel:GetComponent("UILabel").text = growDesc
  local PetQualityType = PetData.PetQualityType
  local petQuality = self._petData.petQuality
  local petCfgData = self._petData:GetPetCfgData()
  local function GetQualityTuple(petQualityType)
    return {
      value = petQuality:GetQuality(petQualityType) or 0,
      minValue = petCfgData:GetMinQuality(petQualityType) or 0,
      maxValue = petQuality:GetMaxQuality(petQualityType) or 0
    }
  end
  local qualityTable = {
    GetQualityTuple(PetQualityType.HP_APT),
    GetQualityTuple(PetQualityType.PHYATK_APT),
    GetQualityTuple(PetQualityType.MAGATK_APT),
    GetQualityTuple(PetQualityType.PHYDEF_APT),
    GetQualityTuple(PetQualityType.MAGDEF_APT),
    GetQualityTuple(PetQualityType.SPEED_APT)
  }
  self:SetQualityValue(qualityTable)
end
def.method("table").SetQualityValue = function(self, qualityTable)
  if qualityTable == nil then
    local qualityCount = 6
    qualityTable = {}
    for i = 1, qualityCount do
      qualityTable[i] = {}
    end
  end
  for i, v in ipairs(qualityTable) do
    local ui_Slider = self._uiObjs.Img_Bg0:FindDirect(string.format("Img_CW_BgAttribute/Slider_Attribute%02d", i))
    local ui_Label = GUIUtils.FindDirect(ui_Slider, string.format("Label_AttributeSlider%02d", i))
    local value, maxValue, minValue = v.value, v.maxValue, v.minValue
    local progress = 0
    if value and maxValue and minValue then
      progress = PetUtility.GetPetQualityProgress(value, minValue, maxValue)
    end
    GUIUtils.SetProgress(ui_Slider, "UIProgressBar", progress)
    local text = ""
    if value and maxValue then
      text = string.format("%d/%d", value, maxValue)
    end
    GUIUtils.SetText(ui_Label, text)
  end
end
def.method()._SetPetSkills = function(self)
  local skillGrid = self._uiObjs.Img_Skill:FindDirect("Img_BgSkillGroup/Scroll View/Grid_Skill")
  local skillIdList = self._petData:GetConcatSkillIdList() or {}
  local skillMountsIdList = self._petData:GetProtectMountsSkillIdList() or {}
  for _, v in ipairs(skillMountsIdList) do
    table.insert(skillIdList, v)
  end
  local petMarkSkillId = self._petData:GetPetMarkSkillId()
  if petMarkSkillId > 0 then
    table.insert(skillIdList, petMarkSkillId)
  end
  for i = 1, #skillIdList do
    local skillId = skillIdList[i]
    local itemObj = skillGrid:FindDirect(string.format("Img_BgSkill%02d", i))
    if skillId then
      PetUtility.SetPetSkillBgColor(itemObj, skillId)
      local skillCfg = PetUtility.Instance():GetPetSkillCfg(skillId)
      if skillCfg.iconId == 0 then
        warn(string.format("skill(%s)'s iconId == 0", skillCfg.name))
      end
      local uiTexture = itemObj:FindDirect(string.format("Img_IconSkill%02d", i)):GetComponent("UITexture")
      GUIUtils.FillIcon(uiTexture, skillCfg.iconId)
    end
  end
end
def.method()._SetPetModel = function(self)
  local objModel = self._uiObjs.Img_Bg0:FindDirect("Img_BgImage0/Model_CW")
  local uiModel = objModel:GetComponent("UIModel")
  if self._model ~= nil then
    self._model:Destroy()
    self._model = nil
  end
  self._model = PetUtility.CreateAndAttachPetUIModel(self._petData, uiModel, nil)
end
def.method()._SetEquipment = function(self)
  local equipments = self._petData.equipments or {}
  local equipmentSlotTable = {
    {
      equipments[PetData.PetEquipmentType.EQUIP_NECKLACE]
    },
    {
      equipments[PetData.PetEquipmentType.EQUIP_HELMET]
    },
    {
      equipments[PetData.PetEquipmentType.EQUIP_AMULET]
    }
  }
  local Group_Items = self._uiObjs.Img_Bg0:FindDirect("Img_BgImage0/Group_Items")
  for i, value in ipairs(equipmentSlotTable) do
    local v = value[1]
    local Img_BgEquip = Group_Items:FindDirect(string.format("Img_BgEquip%02d", i))
    local Img_IconEquip = Img_BgEquip:FindDirect(string.format("Img_IconEquip%02d", i))
    local Img_Empty = Img_BgEquip:FindDirect("Img_Empty")
    if v then
      local itemId = v.id
      local itemBase = ItemUtils.GetItemBase(itemId)
      GUIUtils.SetTexture(Img_IconEquip, itemBase.icon)
      GUIUtils.SetActive(Img_Empty, false)
    else
      GUIUtils.SetTexture(Img_IconEquip, 0)
      GUIUtils.SetActive(Img_Empty, true)
    end
  end
  if self._petData.isDecorated then
    Group_Items:FindDirect("Img_BgEquip04/Img_CW_IconEquip04"):SetActive(true)
    Group_Items:FindDirect("Img_BgEquip04/Img_Empty"):SetActive(false)
  else
    Group_Items:FindDirect("Img_BgEquip04/Img_CW_IconEquip04"):SetActive(false)
    Group_Items:FindDirect("Img_BgEquip04/Img_Empty"):SetActive(true)
  end
end
def.method()._ClearPetStageLevel = function(self)
  local stageStar = self._uiObjs.Img_Bg0:FindDirect("Img_BgImage0/Img_Jiewei")
  if stageStar ~= nil then
    stageStar:SetActive(false)
  end
end
def.method("number")._SetPetStageLevel = function(self, stageLevel)
  local stageStar = self._uiObjs.Img_Bg0:FindDirect("Img_BgImage0/Img_Jiewei")
  if stageStar ~= nil then
    stageStar:SetActive(true)
    GUIUtils.SetSprite(stageStar, "Img_Jie" .. stageLevel)
  end
end
def.override().OnShare = function(self)
  self._uiObjs.Img_Logo:SetActive(true)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  end
end
def.override().OnDestroy = function(self)
  self._uiObjs = nil
  if self._model ~= nil then
    self._model:Destroy()
    self._model = nil
  end
end
PetSharePanel.Commit()
return PetSharePanel
