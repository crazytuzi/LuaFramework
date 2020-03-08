local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetInfoPanel = Lplus.Extend(ECPanelBase, "PetInfoPanel")
local def = PetInfoPanel.define
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local PetData = Lplus.ForwardDeclare("PetData")
local PetUtility = require("Main.Pet.PetUtility")
local PetModule = require("Main.Pet.PetModule")
local GUIUtils = require("GUI.GUIUtils")
local QualityType = require("netio.protocol.mzm.gsp.pet.CLianGuReq")
local ECModel = require("Model.ECModel")
local ItemModule = require("Main.Item.ItemModule")
local ItemUtils = require("Main.Item.ItemUtils")
local ItemTipsMgr = require("Main.Item.ItemTipsMgr")
def.const("table").equipmentSlotOrder = {
  PetData.PetEquipmentType.EQUIP_NECKLACE,
  PetData.PetEquipmentType.EQUIP_HELMET,
  PetData.PetEquipmentType.EQUIP_AMULET
}
def.const("table").ArrowState = {
  None = 0,
  Left = 1,
  Right = 2,
  Both = 3
}
def.field("table")._petData = nil
def.field("table")._model = nil
def.field("boolean").isDrag = false
def.field("table").uiObjs = nil
def.field("userdata").ui_Img_Bg0 = nil
def.field("userdata").ui_Img_Skill = nil
def.field("number").level = 1
def.field("number").arrowState = 0
def.field("function").arrowCallback = nil
def.field("function").shareCallback = nil
local instance
def.static("=>", PetInfoPanel).Instance = function()
  if instance == nil then
    instance = PetInfoPanel()
  end
  return instance
end
def.method("number").SetPanelLevel = function(self, level)
  self.level = level
end
def.method(PetData, "=>", PetInfoPanel).ShowPanel = function(self, petData)
  self._petData = petData
  if self:IsShow() then
    self:UpdateUI()
    return self
  end
  self:CreatePanel(RESPATH.PREFAB_PET_INFO_PANEL_RES, self.level)
  self:SetModal(true)
  return self
end
def.method("table", "=>", PetInfoPanel).ShowPanelByPetInfo = function(self, petInfo)
  local petData = PetData()
  petData:RawSet(petInfo)
  return self:ShowPanel(petData)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
  self:Clear()
end
def.override().OnCreate = function(self)
  self:HandleEventListeners(true)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnDestroy = function(self)
  self:HandleEventListeners(false)
  self._petData = nil
  if self._model then
    self._model:Destroy()
    self._model = nil
  end
  self.uiObjs = nil
  self.ui_Img_Bg0 = nil
  self.ui_Img_Skill = nil
  self.level = 1
  self.arrowState = PetInfoPanel.ArrowState.None
  self.arrowCallback = nil
  self.shareCallback = nil
end
def.method().Init = function(self)
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, #"Img_BgSkill") == "Img_BgSkill" then
    local index = tonumber(string.sub(id, #"Img_BgSkill" + 1, -1))
    self:OnPetSkillIconClick(index)
  elseif string.sub(id, 1, 12) == "Img_BgEquip0" then
    local index = tonumber(string.sub(id, 13, -1))
    self:OnPetEquipmentClick(index)
  elseif id == "Model_CW" then
    self:OnClickPetModel()
  elseif id == "Btn_Right" then
    self:OnArrowClick(1)
  elseif id == "Btn_Left" then
    self:OnArrowClick(-1)
  elseif id == "Img_JieWei" then
    self:OnPetStageLevelClick()
  elseif id == "Btn_Share" then
    self:OnShareBtnClick()
  else
    self:CheckSoulClick(id)
  end
end
def.method().Clear = function(self)
end
def.method().InitUI = function(self)
  self.ui_Img_Bg0 = self.m_panel:FindDirect("Img_Bg0")
  self.ui_Img_Skill = self.m_panel:FindDirect("Img_Skill")
  self.uiObjs = {}
  self.uiObjs.Img_BgPower = self.m_panel:FindDirect("Img_BgPower")
  self.uiObjs.Group_Btn = self.m_panel:FindDirect("Group_Btn")
  if self.uiObjs.Group_Btn then
    self.uiObjs.Btn_Left = self.uiObjs.Group_Btn:FindDirect("Btn_Left")
    self.uiObjs.Btn_Right = self.uiObjs.Group_Btn:FindDirect("Btn_Right")
  end
  self.uiObjs.Btn_Share = self.ui_Img_Bg0:FindDirect("Btn_Share")
  GUIUtils.SetActive(self.uiObjs.Btn_Share, ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK)
  local PetSoulPos = require("consts.mzm.gsp.petsoul.confbean.PetSoulPos")
  self.uiObjs.Btn_Sprites = self.ui_Img_Bg0:FindDirect("Btn_Sprites")
  self.uiObjs.SoulPos2BtnMap = {}
  self.uiObjs.SoulPos2BtnMap[PetSoulPos.POS_JING] = self.uiObjs.Btn_Sprites:FindDirect("Img_Icon01")
  self.uiObjs.SoulPos2BtnMap[PetSoulPos.POS_QI] = self.uiObjs.Btn_Sprites:FindDirect("Img_Icon02")
  self.uiObjs.SoulPos2BtnMap[PetSoulPos.POS_SHEN] = self.uiObjs.Btn_Sprites:FindDirect("Img_Icon03")
  self.uiObjs.Btn2SoulPosMap = {}
  for pos, btn in pairs(self.uiObjs.SoulPos2BtnMap) do
    self.uiObjs.Btn2SoulPosMap[btn.name] = pos
  end
end
def.method().UpdateUI = function(self)
  if self._petData == nil then
    return
  end
  local m_panel = self.m_panel
  local Img_BgPetName = self.ui_Img_Bg0:FindDirect("Img_BgPetName")
  GUIUtils.SetText(Img_BgPetName:FindDirect("Label_PetName"), self._petData.name)
  local text = string.format(textRes.Common[3], self._petData.level)
  GUIUtils.SetText(Img_BgPetName:FindDirect("Label_Lv"), text)
  self:UpdatePropValue()
  self:UpdateQualityValue()
  self:UpdateSkillList()
  self:UpdateModel()
  self:UpdateEquipment()
  self:UpdateArrow()
  self:UpdateShareBtn()
  self:SetPetChangeModelCardType()
  if self._petData:CanJinjie() then
    self:SetPetStageLevel(self._petData.stageLevel)
  else
    self:ClearPetStageLevel()
  end
  self:SetPetDisplayModelName()
  self:UpdateSoul()
end
def.method("string").CheckSoulClick = function(self, id)
  local soulPos = self.uiObjs.Btn2SoulPosMap[id]
  warn("[PetInfoPanel:CheckSoulClick] click on soul pos:", soulPos)
  if soulPos then
    local soulProp = self._petData and self._petData.soulProp
    local soulInfo = soulProp and soulProp:GetSoulInfoByPos(soulPos)
    if nil == soulInfo then
      soulInfo = {}
      soulInfo.pos = soulPos
    end
    local PetSoulTip = require("Main.Pet.soul.ui.PetSoulTip")
    PetSoulTip.ShowPanel(nil, soulInfo)
  end
end
def.method().UpdateSoul = function(self)
  local PetSoulMgr = require("Main.Pet.soul.PetSoulMgr")
  local PetSoulUtils = require("Main.Pet.soul.PetSoulUtils")
  if PetSoulMgr.Instance():IsOpen(false) then
    GUIUtils.SetActive(self.uiObjs.Btn_Sprites, true)
    PetSoulUtils.ShowSouls(self._petData and self._petData.soulProp, self.uiObjs.SoulPos2BtnMap)
  else
    GUIUtils.SetActive(self.uiObjs.Btn_Sprites, false)
  end
end
def.method("number").OnArrowClick = function(self, dir)
  if self.arrowCallback then
    local ret = self.arrowCallback(dir)
    if ret == true then
      self:DestroyPanel()
    end
  end
end
def.method().UpdateArrow = function(self)
  local arrows = self.uiObjs.Group_Btn
  local leftArrow = self.uiObjs.Btn_Left
  local rightArrow = self.uiObjs.Btn_Right
  if self.arrowState == PetInfoPanel.ArrowState.None then
    GUIUtils.SetActive(arrows, false)
  elseif self.arrowState == PetInfoPanel.ArrowState.Both then
    GUIUtils.SetActive(arrows, true)
    GUIUtils.SetActive(leftArrow, true)
    GUIUtils.SetActive(rightArrow, true)
  elseif self.arrowState == PetInfoPanel.ArrowState.Left then
    GUIUtils.SetActive(arrows, true)
    GUIUtils.SetActive(leftArrow, true)
    GUIUtils.SetActive(rightArrow, false)
  elseif self.arrowState == PetInfoPanel.ArrowState.Right then
    GUIUtils.SetActive(arrows, true)
    GUIUtils.SetActive(leftArrow, false)
    GUIUtils.SetActive(rightArrow, true)
  end
end
def.method().OnShareBtnClick = function(self)
  if self.shareCallback then
    local Vector = require("Types.Vector")
    local go = self.uiObjs.Btn_Share
    local position = go.position
    local screenPos = WorldPosToScreen(position.x, position.y)
    local widget = go:GetComponent("UIWidget")
    local pos = {
      auto = true,
      prefer = 0,
      preferY = 1
    }
    pos.sourceX = screenPos.x
    pos.sourceY = screenPos.y
    pos.sourceW = widget.width
    pos.sourceH = widget.height
    local ret = self.shareCallback(pos)
    if ret == true then
      self:DestroyPanel()
    end
  end
end
def.method().UpdateShareBtn = function(self)
  if self.shareCallback and ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    GUIUtils.SetActive(self.uiObjs.Btn_Share, true)
  else
    GUIUtils.SetActive(self.uiObjs.Btn_Share, false)
  end
end
def.method("function").SetShareCallback = function(self, callback)
  self.shareCallback = callback
  if self.m_panel then
    self:UpdateShareBtn()
  end
end
def.method().UpdatePropValue = function(self)
  local m_panel = self.m_panel
  local pet = self._petData
  local secondProp = self._petData.secondProp
  local secondPropList = {
    secondProp.maxHp,
    secondProp.maxMp,
    secondProp.phyAtk,
    secondProp.magAtk,
    secondProp.phyDef,
    secondProp.magDef,
    secondProp.speed
  }
  local ui_Img_CW_BgBasic = self.ui_Img_Bg0:FindDirect("Img_CW_BgBasic")
  for i, value in ipairs(secondPropList) do
    local labelName = string.format("Img_CW_BgAttribute0%d/Label_CW_AttributeNum0%d", i, i)
    ui_Img_CW_BgBasic:FindDirect(labelName):GetComponent("UILabel"):set_text(value)
  end
  local value = self._petData.life
  if self._petData:IsNeverDie() then
    value = textRes.Pet[45]
  end
  local labelName = string.format("Img_CW_BgAttribute0%d/Label_CW_AttributeNum0%d", 8, 8)
  ui_Img_CW_BgBasic:FindDirect(labelName):GetComponent("UILabel"):set_text(value)
  local viewData = PetUtility.GetPetGrowValueViewData(self._petData)
  local text = string.format("[%s]%s(%s)[-]", viewData.color, viewData.value, viewData.meaning)
  self.ui_Img_Bg0:FindDirect("Img_CW_BgAttribute/Img_BgGrown/Label_GrownNum"):GetComponent("UILabel"):set_text(text)
  local ui_Img_BgImage0 = self.ui_Img_Bg0:FindDirect("Img_BgImage0")
  local petCfgData = self._petData:GetPetCfgData()
  local typeText = textRes.Pet.Type[petCfgData.type]
  ui_Img_BgImage0:FindDirect("Label_PetType"):GetComponent("UILabel"):set_text(typeText)
  ui_Img_BgImage0:FindDirect("Img_PetType"):GetComponent("UISprite").spriteName = PetUtility.GetPetTypeSpriteName(petCfgData.type)
  if petCfgData.isSpecial then
    ui_Img_BgImage0:FindDirect("Img_Zhuan"):SetActive(true)
  elseif self._petData.isBinded then
    ui_Img_BgImage0:FindDirect("Img_Zhuan"):SetActive(false)
    ui_Img_BgImage0:FindDirect("Img_Bang"):SetActive(true)
  else
    ui_Img_BgImage0:FindDirect("Img_Zhuan"):SetActive(false)
    ui_Img_BgImage0:FindDirect("Img_Bang"):SetActive(false)
  end
  local carrayLevel = petCfgData.carryLevel
  local Label_Lv = ui_Img_BgImage0:FindDirect("Label_Lv")
  Label_Lv:GetComponent("UILabel").text = string.format(textRes.Pet[107], carrayLevel)
  local Btn_NotDecorated = ui_Img_BgImage0:FindDirect("Btn_Decoration01")
  local Btn_Decorated = ui_Img_BgImage0:FindDirect("Btn_Decoration02")
  GUIUtils.SetActive(Btn_NotDecorated, not pet.isDecorated)
  GUIUtils.SetActive(Btn_Decorated, pet.isDecorated)
  self:UpdateYaoLi()
end
def.method().UpdateYaoLi = function(self)
  local ui_Img_BgImage0 = self.ui_Img_Bg0:FindDirect("Img_BgImage0")
  local pet = self._petData
  PetUtility.SetYaoLiUIFromPet(self.uiObjs.Img_BgPower, pet)
end
def.method().UpdateQualityValue = function(self)
  local ui_Img_CW_BgAttribute = self.ui_Img_Bg0:FindDirect("Img_CW_BgAttribute")
  local pet = self._petData
  local PetQualityType = PetData.PetQualityType
  local petQuality = pet.petQuality
  local petCfgData = pet:GetPetCfgData()
  local function GetQualityTuple(petQualityType)
    return {
      value = petQuality:GetQuality(petQualityType) or 0,
      minValue = petCfgData:GetMinQuality(petQualityType) or 0,
      maxValue = petQuality:GetMaxQuality(petQualityType) or 0
    }
  end
  local qualityList = {
    GetQualityTuple(PetQualityType.HP_APT),
    GetQualityTuple(PetQualityType.PHYATK_APT),
    GetQualityTuple(PetQualityType.MAGATK_APT),
    GetQualityTuple(PetQualityType.PHYDEF_APT),
    GetQualityTuple(PetQualityType.MAGDEF_APT),
    GetQualityTuple(PetQualityType.SPEED_APT)
  }
  for i, v in ipairs(qualityList) do
    local ui_Slider_Attribute = ui_Img_CW_BgAttribute:FindDirect("Slider_Attribute0" .. i)
    local ui_Label_AttributeSlider = GUIUtils.FindDirect(ui_Slider_Attribute, "Label_AttributeSlider0" .. i)
    local value, maxValue, minValue = v.value, v.maxValue, v.minValue
    local progress = 0
    if value and maxValue and minValue then
      progress = PetUtility.GetPetQualityProgress(value, minValue, maxValue)
    end
    GUIUtils.SetProgress(ui_Slider_Attribute, "UIProgressBar", progress)
    local text = string.format("%d/%d", v.value, v.maxValue)
    GUIUtils.SetText(ui_Label_AttributeSlider, text)
  end
end
def.method().UpdateSkillList = function(self)
  local pet = self._petData
  local grid = self.ui_Img_Skill:FindDirect("Img_BgSkillGroup/Scroll View/Grid_Skill"):GetComponent("UIGrid")
  PetUtility.SetSkillList(pet, grid, "Img_IconSkill", "Img_Sign", "Img_Sign0", "Img_RidingSign", "Img_ImpressSign", nil, false)
end
def.method().UpdateEquipment = function(self)
  local pet = self._petData
  local equipments = pet.equipments or {}
  local equipmentSlotTable = {
    {
      equipments[PetInfoPanel.equipmentSlotOrder[1]]
    },
    {
      equipments[PetInfoPanel.equipmentSlotOrder[2]]
    },
    {
      equipments[PetInfoPanel.equipmentSlotOrder[3]]
    }
  }
  local ui_Img_BgImage0 = self.ui_Img_Bg0:FindDirect("Img_BgImage0")
  for i, value in ipairs(equipmentSlotTable) do
    local v = value[1]
    local Img_CW_BgEquip = ui_Img_BgImage0:FindDirect(string.format("Img_BgEquip0%d", i))
    local Img_CW_IconEquip = Img_CW_BgEquip:FindDirect(string.format("Img_IconEquip0%d", i))
    local Img_CW_Empty = Img_CW_BgEquip:FindDirect("Img_Empty")
    if v then
      local itemId = v.id
      local itemBase = ItemUtils.GetItemBase(itemId)
      GUIUtils.SetTexture(Img_CW_IconEquip, itemBase.icon)
      GUIUtils.SetActive(Img_CW_Empty, false)
    else
      GUIUtils.SetTexture(Img_CW_IconEquip, 0)
      GUIUtils.SetActive(Img_CW_Empty, true)
    end
  end
end
def.method().UpdateModel = function(self)
  local pet = self._petData
  local petCfgData = pet:GetPetCfgData()
  local objModel = self.ui_Img_Bg0:FindDirect("Img_BgImage0/Model_CW")
  objModel:GetComponent("UIWidget"):set_depth(21)
  local uiModel = objModel:GetComponent("UIModel")
  local modelPath = GetModelPath(petCfgData.modelId)
  if self._model ~= nil then
    self._model:Destroy()
  end
  self._model = PetUtility.CreateAndAttachPetUIModel(pet, uiModel, nil)
end
def.method().ClearPetStageLevel = function(self)
  local stageStar = self.ui_Img_Bg0:FindDirect("Img_BgImage0/Img_JieWei")
  if stageStar ~= nil then
    stageStar:SetActive(false)
  end
end
def.method("number").SetPetStageLevel = function(self, stageLevel)
  local stageStar = self.ui_Img_Bg0:FindDirect("Img_BgImage0/Img_JieWei")
  if stageStar ~= nil then
    stageStar:SetActive(true)
    GUIUtils.SetSprite(stageStar, "Img_Jie" .. stageLevel)
    PetUtility.AddBoxCollider(stageStar)
  end
end
def.method().SetPetDisplayModelName = function(self)
  local pet = self._petData
  local modelName = self.ui_Img_Bg0:FindDirect("Img_BgImage0/Label_ChangeName")
  GUIUtils.SetActive(modelName, true)
  if pet.extraModelCfgId ~= 0 then
    local displayModelInfo = ItemUtils.GetItemBase(pet.extraModelCfgId)
    if displayModelInfo ~= nil then
      GUIUtils.SetText(modelName, string.format(textRes.Pet[218], displayModelInfo.name))
    else
      GUIUtils.SetText(modelName, "")
    end
  else
    GUIUtils.SetText(modelName, "")
  end
end
def.method().SetPetChangeModelCardType = function(self)
  local pet = self._petData
  local Img_Tpye = self.ui_Img_Bg0:FindDirect("Img_BgImage0/Img_Tpye")
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(Img_Tpye, 0)
  else
    local petCfgData = pet:GetPetCfgData()
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(petCfgData.changeModelCardClassType)
    GUIUtils.SetTexture(Img_Tpye, classCfg.smallIconId)
  end
end
def.method("string").onDragStart = function(self, id)
  print("onDragStart", id)
  if id == "Model_CW" then
    self.isDrag = true
  end
end
def.method("string").onDragEnd = function(self, id)
  self.isDrag = false
end
def.method("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self.isDrag == true and self._model then
    self._model:SetDir(self._model.m_ang - dx / 2)
  end
end
def.method("number").OnPetSkillIconClick = function(self, index)
  local pet = self._petData
  local skillIdList = pet:GetConcatSkillIdList()
  local petMarkSkillId = pet:GetPetMarkSkillId()
  if petMarkSkillId > 0 then
    table.insert(skillIdList, petMarkSkillId)
  end
  local skillId = skillIdList[index]
  if skillId == nil then
    return
  end
  local sourceObj = self.ui_Img_Skill:FindDirect(string.format("Img_BgSkillGroup"))
  PetUtility.ShowPetSkillTipEx(skillId, pet.level, sourceObj, 0)
end
def.method("number").OnPetEquipmentClick = function(self, index)
  local pet = self._petData
  local equipments = pet.equipments or {}
  local equipment = equipments[PetInfoPanel.equipmentSlotOrder[index]]
  if equipment then
    local sourceObj = self.ui_Img_Bg0:FindDirect(string.format("Img_BgImage0/Img_BgEquip%02d", index))
    PetUtility.ShowPetEquipmentTip(equipment, sourceObj)
  else
  end
end
def.method().OnClickPetModel = function(self)
  PetUtility.PlayPetClickedAnimation(self._model)
end
def.method("string", "boolean").onPress = function(self, id, state)
  if id == "Img_BgPower" then
    self:OnYaoLiPressInfo(state)
  end
end
def.method("boolean").OnYaoLiPressInfo = function(self, state)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  if state == false then
    CommonUISmallTip.Instance():HideTip()
    return
  end
  local position = UICamera.lastWorldPosition
  local screenPos = WorldPosToScreen(position.x, position.y)
  local CommonUISmallTip = require("GUI.CommonUISmallTip")
  CommonUISmallTip.Instance():ShowTip(textRes.Pet[139], screenPos.x, screenPos.y, 10, 10, -1)
end
def.method().OnPetStageLevelClick = function(self)
  local pet = self._petData
  PetUtility.ShowPetStageLevelTips(pet)
end
def.method("boolean").HandleEventListeners = function(self, isRigister)
  local eventFunc
  if isRigister then
    eventFunc = Event.RegisterEvent
  else
    eventFunc = Event.UnregisterEvent
  end
  if eventFunc then
    eventFunc(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, PetInfoPanel.OnFeatureOpenChange)
  end
end
def.static("table", "table").OnFeatureOpenChange = function(param, context)
  local self = PetInfoPanel.Instance()
  if self:IsShow() then
    local ModuleFunSwitchInfo = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
    if param.feature == ModuleFunSwitchInfo.TYPE_PET_SOUL then
      self:UpdateSoul()
    end
  end
end
return PetInfoPanel.Commit()
