local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetPanelNodeBase = require("Main.Pet.ui.PetPanelNodeBase")
local PetMgr = require("Main.Pet.mgr.PetMgr")
local PetMgrInstance = PetMgr.Instance()
local PetUtility = require("Main.Pet.PetUtility")
local PetData = Lplus.ForwardDeclare("PetData")
local GUIUtils = require("GUI.GUIUtils")
local PetSoulPos = require("consts.mzm.gsp.petsoul.confbean.PetSoulPos")
local PetSoulUtils = require("Main.Pet.soul.PetSoulUtils")
local PetSoulData = require("Main.Pet.soul.data.PetSoulData")
local PetPanelSoulNode = Lplus.Extend(PetPanelNodeBase, "PetPanelSoulNode")
local def = PetPanelSoulNode.define
local instance
def.static("=>", PetPanelSoulNode).Instance = function()
  if instance == nil then
    instance = PetPanelSoulNode()
  end
  return instance
end
local NOT_SELECTED = 0
def.field("table")._uiObjs = nil
def.field("table")._petModel = nil
def.field("boolean")._IsModelDrag = false
def.override(ECPanelBase, "userdata").Init = function(self, base, node)
  PetPanelNodeBase.Init(self, base, node)
end
def.override().OnShow = function(self)
  self:InitUI()
  self:UpdateUI()
end
def.override().OnHide = function(self)
  self:ClearModel()
  self._uiObjs = nil
end
def.override().InitUI = function(self)
  PetPanelNodeBase.InitUI(self)
  self._uiObjs = {}
  self._uiObjs.PetList = self.m_panel:FindDirect("Img_Bg0/PetList")
  self._uiObjs.Group_PetInfo = self.m_node:FindDirect("Img_ZB_BgImage0")
  self._uiObjs.Img_BgPower = self._uiObjs.Group_PetInfo:FindDirect("Img_BgPower")
  self._uiObjs.Label_PetName = self._uiObjs.Group_PetInfo:FindDirect("Label_PetName01")
  self._uiObjs.Label_PetType = self._uiObjs.Group_PetInfo:FindDirect("Label_CW_PetType")
  self._uiObjs.Img_JieWei = self._uiObjs.Group_PetInfo:FindDirect("Img_JieWei")
  self._uiObjs.Model = self._uiObjs.Group_PetInfo:FindDirect("Model_CW")
  self._uiObjs.Label_LevelLimited = self._uiObjs.Group_PetInfo:FindDirect("Label_LevelLimited")
  self._uiObjs.Label_PowerNum = self._uiObjs.Group_PetInfo:FindDirect("Label_PowerNum")
  self._uiObjs.Btn_ChangName = self._uiObjs.Group_PetInfo:FindDirect("Btn_ChangName")
  self._uiObjs.Group_Soul = self.m_node:FindDirect("Group_PetProperty")
  self._uiObjs.Img_Bg = self._uiObjs.Group_Soul:FindDirect("Img_Bg")
  self._uiObjs.SoulPos2BtnMap = {}
  self._uiObjs.SoulPos2BtnMap[PetSoulPos.POS_JING] = self._uiObjs.Group_Soul:FindDirect("Img_Bg/Btn_Sprites/Img_Icon01")
  self._uiObjs.SoulPos2BtnMap[PetSoulPos.POS_QI] = self._uiObjs.Group_Soul:FindDirect("Img_Bg/Btn_Sprites/Img_Icon02")
  self._uiObjs.SoulPos2BtnMap[PetSoulPos.POS_SHEN] = self._uiObjs.Group_Soul:FindDirect("Img_Bg/Btn_Sprites/Img_Icon03")
  self._uiObjs.Btn2SoulPosMap = {}
  for pos, btn in pairs(self._uiObjs.SoulPos2BtnMap) do
    self._uiObjs.Btn2SoulPosMap[btn.name] = pos
  end
  self._uiObjs.List_Attrs = self._uiObjs.Group_Soul:FindDirect("Img_Bg/List_Buff")
  self._uiObjs.uiListAttrs = self._uiObjs.List_Attrs:GetComponent("UIList")
  self._uiObjs.Label_Tip = self.m_node:FindDirect("Img_Bg_Explaination/Label")
  self._uiObjs.Img_FS_PetDept = self._uiObjs.Group_PetInfo:FindDirect("Label_FS_PetDept")
end
def.override().UpdateUI = function(self)
  GUIUtils.SetActive(self._uiObjs.PetList, true)
  self.m_base:SetPetList(PetMgrInstance.petList, PetMgrInstance.petNum)
  self.m_base:UpdateTuJianNotice()
  if PetMgrInstance:GetPetNum() == 0 then
    self.isEmpty = true
    self:ShowEmptyPage()
    return
  end
  self.isEmpty = false
  self:UpdateSelectedIndex()
  local pet = PetMgr.Instance():GetPet(self.m_base.selectedPetId)
  self:SetPetInfo(self.m_base.selectedPetIndex, pet)
  GUIUtils.SetText(self._uiObjs.Label_Tip, textRes.Pet.Soul.PET_SOUL_NODE_TIP)
end
def.method().ShowEmptyPage = function(self)
  GUIUtils.SetActive(self._uiObjs.Label_PetName, false)
  GUIUtils.SetActive(self._uiObjs.Img_BgPower, false)
  GUIUtils.SetActive(self._uiObjs.Label_PetType, false)
  GUIUtils.SetActive(self._uiObjs.Label_LevelLimited, false)
  GUIUtils.SetActive(self._uiObjs.Img_JieWei, false)
  GUIUtils.SetActive(self._uiObjs.Btn_ChangName, false)
  GUIUtils.SetTexture(self._uiObjs.Img_FS_PetDept, 0)
  self:UpdateSoulInfo(nil)
end
def.method().UpdateSelectedIndex = function(self)
  self.m_base.selectedPetIndex = NOT_SELECTED
  for index, petId in ipairs(self.m_base.petIdList) do
    if petId == self.m_base.selectedPetId then
      self.m_base.selectedPetIndex = index
      break
    end
  end
  local index
  if self.m_base.selectedPetIndex == NOT_SELECTED and self.m_base.petIdList[1] then
    index = 1
  else
    index = self.m_base.selectedPetIndex
  end
  self:SetSelectedPet(index)
  self.m_base:SetSelectedListItem(index)
end
def.method("number").SetSelectedPet = function(self, index)
  self.m_base.selectedPetIndex = index
  self.m_base.selectedPetId = self.m_base.petIdList[index]
end
def.method("number", "table").SetPetInfo = function(self, index, pet)
  self:ClearModel()
  if pet then
    GUIUtils.SetActive(self._uiObjs.Label_PetName, true)
    GUIUtils.SetActive(self._uiObjs.Img_BgPower, true)
    GUIUtils.SetActive(self._uiObjs.Label_PetType, true)
    GUIUtils.SetActive(self._uiObjs.Label_LevelLimited, true)
    GUIUtils.SetActive(self._uiObjs.Img_JieWei, true)
    GUIUtils.SetActive(self._uiObjs.Btn_ChangName, true)
    GUIUtils.SetText(self._uiObjs.Label_PetName, pet.name)
    PetUtility.SetYaoLiUIFromPet(self._uiObjs.Img_BgPower, pet)
    local petCfgData = pet:GetPetCfgData()
    if petCfgData then
      local spriteName = PetUtility.GetPetTypeSpriteName(petCfgData.type)
      GUIUtils.SetSprite(self._uiObjs.Label_PetType, spriteName)
      local levelStr = string.format(textRes.Pet[152], petCfgData.carryLevel)
      GUIUtils.SetText(self._uiObjs.Label_LevelLimited, levelStr)
    else
      warn("[ERROR][PetPanelSoulNode:SetPetInfo] petCfgData nil for pos:", pet.typeId)
      GUIUtils.SetActive(self._uiObjs.Label_PetType, false)
      GUIUtils.SetActive(self._uiObjs.Label_LevelLimited, false)
    end
    if pet:CanJinjie() then
      GUIUtils.SetSprite(self._uiObjs.Img_JieWei, "Img_Jie" .. pet.stageLevel)
      PetUtility.AddBoxCollider(self._uiObjs.Img_JieWei)
    else
      GUIUtils.SetActive(self._uiObjs.Img_JieWei, false)
    end
    self:UpdateModel(pet)
    self:UpdateSoulInfo(pet)
    self:SetPetChangeModelCardType(pet)
  else
    warn("[PetPanelSoulNode:SetPetInfo] pet nil for index:", index)
    self:ShowEmptyPage()
  end
end
def.method(PetData).UpdateSoulInfo = function(self, pet)
  PetSoulUtils.ShowPetSoul(pet, self._uiObjs.Img_Bg, true)
end
def.method(PetData).UpdateModel = function(self, pet)
  local uiModel = self._uiObjs.Model:GetComponent("UIModel")
  if self._petModel ~= nil then
    self._petModel:Destroy()
  end
  self._petModel = PetUtility.CreateAndAttachPetUIModel(pet, uiModel, nil)
end
def.method("table").SetPetChangeModelCardType = function(self, pet)
  if not _G.IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHANGE_MODEL_CARD) then
    GUIUtils.SetTexture(self._uiObjs.Img_FS_PetDept, 0)
  else
    local petCfgData = pet:GetPetCfgData()
    local TurnedCardUtils = require("Main.TurnedCard.TurnedCardUtils")
    local classCfg = TurnedCardUtils.GetCardClassCfg(petCfgData.changeModelCardClassType)
    GUIUtils.SetTexture(self._uiObjs.Img_FS_PetDept, classCfg.smallIconId)
  end
end
def.method().ClearModel = function(self)
  if self._petModel then
    self._petModel:Destroy()
    self._petModel = nil
  end
end
def.override("userdata").OnPetAdded = function(self, petId)
  self.m_base.petIdList = self.m_base.petIdList or {}
  self.m_base:SetPetList(PetMgrInstance.petList, PetMgrInstance.petNum)
  if self.isEmpty then
    self.isEmpty = false
    self:SetSelectedPet(1)
    self.m_base:SetSelectedListItem(1)
    local pet = PetMgrInstance:GetPet(petId)
    self:SetPetInfo(1, pet)
  else
    local origionPetId = self.m_base.selectedPetId
    local index = 0
    for i, id in pairs(self.m_base.petIdList) do
      if id == origionPetId then
        index = i
        break
      end
    end
    self:SetSelectedPet(index)
    self.m_base:SetSelectedListItem(index)
  end
end
def.override("userdata").OnPetDeleted = function(self, petId)
  self.m_base:SetPetList(PetMgrInstance.petList, PetMgrInstance.petNum)
  if PetMgrInstance.petList == nil or PetMgrInstance.petNum == 0 then
    self.isEmpty = true
    self:SetSelectedPet(NOT_SELECTED)
    self:ShowEmptyPage()
  else
    local index = self.m_base.selectedPetIndex
    local petId = self.m_base.petIdList[index]
    if not petId then
      index = index - 1
    end
    local petId = self.m_base.petIdList[index]
    self:SetSelectedPet(index)
    self.m_base:SetSelectedListItem(index)
    local pet = PetMgrInstance:GetPet(petId)
    self:SetPetInfo(index, pet)
  end
end
def.override().OnBagInfoSynchronized = function(self)
end
def.override("userdata").UpdatePetInfo = function(self, petId)
  self.m_base.petIdList = self.m_base.petIdList or {}
  local index = 0
  for i, id in pairs(self.m_base.petIdList) do
    if id == petId then
      index = i
      break
    end
  end
  local pet = PetMgrInstance:GetPet(petId)
  if index ~= 0 and pet then
    self:SetPetInfo(index, pet)
  end
end
def.override("string").onClick = function(self, id)
  if self.isEmpty then
    return
  end
  if id == "Btn_Tips" then
    self:OnBtn_Tips()
  elseif id == "Btn_ChangName" then
    self:OnRenameButtonClick()
  elseif string.sub(id, 1, 4) == "Pet_" then
    local index = tonumber(string.sub(id, 5, -1))
    self:OnPetItemClick(index)
  elseif id == "Model_CW" then
    self:OnClickPetModel()
  elseif id == "Btn_Promote" then
    self:OnPromoteButtonClicked()
  elseif id == "Img_JieWei" then
    self:OnPetStageLevelClick()
  elseif id == "Btn_Sprite_Transfer" then
    self:OnBtn_Sprite_Transfer()
  else
    self:CheckSoulClick(id)
  end
end
def.method().OnBtn_Tips = function(self)
  local tipId = PetUtility.Instance():GetPetConstants("PET_SOUL_UPGRADE_TIP")
  GUIUtils.ShowHoverTip(tipId)
end
def.method().OnRenameButtonClick = function(self)
  if _G.CheckCrossServerAndToast() then
    return
  end
  local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
  CommonRenamePanel:ShowPanel(textRes.Pet[6], false, PetPanelSoulNode.OnRenamePanelCallback, self)
end
def.static("string", "table", "=>", "boolean").OnRenamePanelCallback = function(name, self)
  if not self:ValidEnteredName(name) then
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name) then
    Toast(textRes.Pet[18])
    return true
  elseif SensitiveWordsFilter.ContainsSensitiveWord(name, "Name") then
    Toast(textRes.Pet[44])
    return true
  elseif name == "" then
    Toast(textRes.Pet[17])
    return true
  else
    local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
    PetMgrInstance:RenamePet(petId, name)
    return false
  end
end
def.method("string", "=>", "boolean").ValidEnteredName = function(self, enteredName)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Login[15])
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Login[14])
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Pet[46])
    end
    return false
  end
end
def.method().OnPromoteButtonClicked = function(self)
  PetUtility.OpenPetBianqingDlg()
end
def.method().OnClickPetModel = function(self)
  PetUtility.PlayPetClickedAnimation(self._petModel)
end
def.method().OnPetStageLevelClick = function(self)
  local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
  local pet = PetMgrInstance:GetPet(petId)
  PetUtility.ShowPetStageLevelTips(pet)
end
def.method("number").OnPetItemClick = function(self, index)
  if index == self.m_base.selectedPetIndex then
    return
  end
  self:SetSelectedPet(index)
  if PetMgrInstance.petList == nil then
    warn("OnPetItemToggle petList = nil")
    return
  end
  local petId = self.m_base.petIdList[index]
  local pet = PetMgrInstance:GetPet(petId)
  self:SetPetInfo(index, pet)
end
def.method().OnBtn_Sprite_Transfer = function(self)
  local PetSoulExchangePanel = require("Main.Pet.soul.ui.PetSoulExchangePanel")
  PetSoulExchangePanel.ShowPanel()
end
def.method("string").CheckSoulClick = function(self, id)
  local soulPos = self._uiObjs.Btn2SoulPosMap[id]
  if soulPos then
    warn("[PetPanelSoulNode:CheckSoulClick] click on soul pos:", soulPos)
    local petId = self.m_base.petIdList[self.m_base.selectedPetIndex]
    local pet = PetMgr.Instance():GetPet(petId)
    local soulProp = pet and pet.soulProp
    local soulInfo = soulProp and soulProp:GetSoulInfoByPos(soulPos)
    if nil == soulInfo then
      soulInfo = {}
      soulInfo.pos = soulPos
    end
    local PetSoulTip = require("Main.Pet.soul.ui.PetSoulTip")
    PetSoulTip.ShowPanel(petId, soulInfo)
  end
end
def.override("string").onDragStart = function(self, id)
  if id == "Model_CW" then
    self._IsModelDrag = true
  end
end
def.override("string").onDragEnd = function(self, id)
  self._IsModelDrag = false
end
def.override("string", "number", "number").onDrag = function(self, id, dx, dy)
  if self._IsModelDrag == true and self._petModel then
    self._petModel:SetDir(self._petModel.m_ang - dx / 2)
  end
end
return PetPanelSoulNode.Commit()
