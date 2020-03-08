local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PetAssignPropPanel = Lplus.Extend(ECPanelBase, "PetAssignPropPanel")
local def = PetAssignPropPanel.define
local EC = require("Types.Vector3")
local Vector3 = EC.Vector3
local PetMgr = require("Main.Pet.mgr.PetMgr").Instance()
local PetAssignPropMgr = require("Main.Pet.mgr.PetAssignPropMgr").Instance()
local PetData = Lplus.ForwardDeclare("PetData")
local GUIUtils = require("GUI.GUIUtils")
local PetUtility = require("Main.Pet.PetUtility")
local AssignPointHelper = require("Main.Common.AssignPointHelper")
def.field("userdata").petId = nil
def.field("boolean").isSetting = false
def.field("boolean").isEnableAutoAssign = false
def.field("string").lastPressedId = ""
local propNameMap = {
  "con",
  "spi",
  "str",
  "sta",
  "dex"
}
local prop2NameMap = {
  "maxHp",
  "maxMp",
  "phyAtk",
  "magAtk",
  "phyDef",
  "magDef",
  "speed"
}
local instance
def.static("=>", PetAssignPropPanel).Instance = function()
  if instance == nil then
    instance = PetAssignPropPanel()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PET_ASSIGN_PROP_PANEL_RES, 2)
  self:SetModal(true)
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
  self:Clear()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SAVE_ASSIGN_PROP_PREFAB_SUCCESS, PetAssignPropPanel.OnSaveAssignPrefabSuccess)
  Event.RegisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetAssignPropPanel.OnPetInfoUpdate)
  self:Fill()
  AssignPointHelper.Instance():RegisterCallbackFuncs({
    OnContinuallyClick = PetAssignPropPanel.OnContinuallyClick,
    OnButtonCalled = PetAssignPropPanel.OnButtonCalled
  })
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_SAVE_ASSIGN_PROP_PREFAB_SUCCESS, PetAssignPropPanel.OnSaveAssignPrefabSuccess)
  Event.UnregisterEvent(ModuleId.PET, gmodule.notifyId.Pet.PET_INFO_UPDATE, PetAssignPropPanel.OnPetInfoUpdate)
  local pet = PetMgr:GetPet(self.petId)
  pet.assignPropScheme:Clear()
  self.isSetting = false
  self.petId = nil
  self.lastPressedId = ""
  AssignPointHelper.Instance():StopPressTimer()
end
def.method("string").onClick = function(self, id)
  print(string.format("%s click event: id = %s", tostring(self), id))
  if id == "Btn_Close" then
    self:HidePanel()
  elseif id == "Modal" then
    self:HidePanel()
  elseif string.sub(id, 1, -3) == "Btn_JDPlan_Add" then
    self:OnIncPropButtonClick(id)
  elseif string.sub(id, 1, -3) == "Btn_JDPlan_Minus" then
    self:OnDecPropButtonClick(id)
  elseif id == "Btn_JDPlanAdd_Wash" then
    self:OnResetPropButtonClick()
  elseif id == "Btn_Confirm" then
    self:OnConfirmButtonClick()
  elseif id == "Btn_JDPlan_UnSelectUse01" then
    self:OnAutoAssignToggleClick()
  elseif id == "Btn_JDPlan_Settle" then
    self:OnAutoAssignPrefabClick()
  elseif id == "Btn_Cancel" then
    self:OnCancelButtonClick()
  elseif id == "Btn_JDPlanAdd_Recommend" then
    self:OnRecommendBtnClicked()
  elseif string.sub(id, 1, 16) == "Img_JDPlan_BgNum" then
    self:OnPropValueClick(id)
  elseif id == "Btn_Tips" then
    self:OnTipsBtnClicked()
    local ECMSDK = require("ProxySDK.ECMSDK")
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.PANELNAME, {
      self.m_panelName
    })
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  self.lastPressedId = id
  if string.sub(id, 1, -3) == "Btn_JDPlan_Add" then
    AssignPointHelper.Instance():TogglePressedButtonTimer(id, AssignPointHelper.PressedButtonType.Inc, state)
  elseif string.sub(id, 1, -3) == "Btn_JDPlan_Minus" then
    AssignPointHelper.Instance():TogglePressedButtonTimer(id, AssignPointHelper.PressedButtonType.Dec, state)
  end
end
def.static("string").OnContinuallyClick = function(id)
  Toast(textRes.Pet[76])
end
def.static("string", "number").OnButtonCalled = function(id, type)
  local self = instance
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  if type == AssignPointHelper.PressedButtonType.Inc then
    self:OnIncPropButtonCalled(id)
  elseif type == AssignPointHelper.PressedButtonType.Dec then
    self:OnDecPropButtonCalled(id)
  end
end
def.method().OnAutoAssignPrefabClick = function(self)
  self:OpenPetAssignPropSettingPanel()
end
def.method().OnRecommendBtnClicked = function(self)
  local petId = self.petId
  local pet = PetMgr:GetPet(petId)
  local petCfg = pet:GetPetCfgData()
  local schemeId = petCfg.defaultAssignPointCfgId
  local defaultScheme = require("Main.Hero.HeroUtility").GetDefaultAssignPropScheme(schemeId)
  if defaultScheme == nil then
    return
  end
  local scheme = pet.assignPropScheme
  scheme:ClearAutoAssigning()
  for propName, value in pairs(defaultScheme) do
    PetAssignPropMgr:SetBasePropSetting(petId, propName, value)
  end
  self:OpenPetAssignPropSettingPanel()
end
def.method().OpenPetAssignPropSettingPanel = function(self)
  require("Main.Pet.ui.PetAutoAssignPropSettingPanel").Instance():ShowPanelEx(self.petId)
end
def.method().OnConfirmButtonClick = function(self)
  local pet = PetMgr:GetPet(self.petId)
  local scheme = pet.assignPropScheme
  if self.isSetting then
    if scheme.autoAssignedPoint ~= scheme.autoAssignPointLimit then
      Toast(textRes.Pet[35])
    else
      PetAssignPropMgr:SaveAssignedPropPrefab(self.petId)
    end
  elseif scheme.manualAssignedPoint ~= 0 then
    PetAssignPropMgr:SaveAssignedProp(self.petId)
  else
    Toast(textRes.Pet[77])
  end
end
def.method().OnCancelButtonClick = function(self)
  self.isSetting = false
  self:UpdateBaseProp()
  local pet = PetMgr:GetPet(self.petId)
  pet.assignPropScheme:Clear()
  self:UpdateSecondProp()
end
def.method("string").OnIncPropButtonClick = function(self, id)
  AssignPointHelper.Instance():OnButtonClick(id)
  self:OnIncPropButtonCalled(id)
end
def.method("string").OnIncPropButtonCalled = function(self, id)
  local index = tonumber(string.sub(id, -1, -1))
  local atrrName = propNameMap[index]
  if self.isSetting then
    PetAssignPropMgr:IncBasePropPrefab(self.petId, atrrName)
  else
    PetAssignPropMgr:IncBaseProp(self.petId, atrrName)
    self:UpdateSecondProp()
  end
  self:UpdateBaseProp()
end
def.method("string").OnDecPropButtonClick = function(self, id)
  AssignPointHelper.Instance():OnButtonClick(id)
  self:OnDecPropButtonCalled(id)
end
def.method("string").OnDecPropButtonCalled = function(self, id)
  local index = tonumber(string.sub(id, -1, -1))
  local atrrName = propNameMap[index]
  if self.isSetting then
    PetAssignPropMgr:DecBasePropPrefab(self.petId, atrrName)
  else
    PetAssignPropMgr:DecBaseProp(self.petId, atrrName)
    self:UpdateSecondProp()
  end
  self:UpdateBaseProp()
end
def.method().OnAutoAssignToggleClick = function(self)
  local pet = PetMgr:GetPet(self.petId)
  local toggle_isAuto = self.m_panel:FindDirect("Img_Bg0/Img_JD/Img_JD_Plan/Group_BtnAdd/Btn_JDPlan_UnSelectUse01"):GetComponent("UIToggle")
  if pet.assignPropScheme.autoAssignedPoint ~= pet.assignPropScheme.autoAssignPointLimit then
    Toast(textRes.Pet[9])
    toggle_isAuto:set_value(false)
    self:OpenPetAssignPropSettingPanel()
  else
    do
      local function enableAutoAssign(isEnable)
        PetAssignPropMgr:EnableAutoAssign(self.petId, isEnable)
      end
      local isAuto = toggle_isAuto:get_value()
      if isAuto then
        local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
        CommonConfirmDlg.ShowConfirm(textRes.Hero[42], textRes.Hero[45], function(s)
          if s == 1 then
            enableAutoAssign(true)
          else
            toggle_isAuto:set_value(false)
          end
        end, nil)
      else
        enableAutoAssign(false)
      end
    end
  end
end
def.method("string").OnPropValueClick = function(self, id)
  local pet = PetMgr:GetPet(self.petId)
  local scheme = pet.assignPropScheme
  local num = tonumber(string.sub(id, -1, -1))
  local propName = propNameMap[num]
  local availablePoint = 0
  local preBaseValue = 0
  if not self.isSetting then
    preBaseValue = scheme:GetManualAssigning()[propName]
    availablePoint = scheme.potentialPoint - scheme.manualAssignedPoint
  else
    preBaseValue = scheme:GetAutoAssigning()[propName]
    availablePoint = scheme.autoAssignPointLimit - scheme.autoAssignedPoint
  end
  if preBaseValue == 0 and availablePoint == 0 then
    return
  end
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():ShowPanelEx(-1, PetAssignPropPanel.OnDigitalKeyboardCallback, {self = self, id = id})
  CommonDigitalKeyboard.Instance():SetPos(-200, -26)
end
def.static("number", "table").OnDigitalKeyboardCallback = function(value, tag)
  local self = tag.self
  local id = tag.id
  local num = tonumber(string.sub(id, -1, -1))
  local propName = propNameMap[num]
  local actualValue = self:UpdateEnteredValue(propName, value)
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():SetEnteredValue(actualValue)
end
def.method("string", "number", "=>", "number").UpdateEnteredValue = function(self, propName, value)
  local petId = self.petId
  local actualValue
  if not self.isSetting then
    actualValue = PetAssignPropMgr:SetBaseProp(petId, propName, value)
    self:UpdateSecondProp()
  else
    actualValue = PetAssignPropMgr:SetBasePropSetting(petId, propName, value)
  end
  self:UpdateBaseProp()
  return actualValue
end
def.method("userdata").SetActivePet = function(self, petId)
  self.petId = petId
end
def.method().Fill = function(self)
  local pet = PetMgr:GetPet(self.petId)
  self:UpdateBaseProp()
  self:UpdateSecondProp()
  self.isEnableAutoAssign = pet.assignPropScheme.isEnableAutoAssign
  self:SetAutoAssignToggleState(pet.assignPropScheme.isEnableAutoAssign)
  self.m_panel:FindChild("Label_JD_AttributeTitle"):GetComponent("UILabel"):set_text(pet.name)
end
def.method().UpdateBaseProp = function(self)
  if self.isSetting then
    self:UpdateBasePropPrefab()
  else
    self:UpdateBasePropAssigned()
  end
  self.m_panel:FindChild("Group_BtnAdd"):SetActive(not self.isSetting)
  self.m_panel:FindChild("Btn_JDPlan_UnSelectUse01"):SetActive(not self.isSetting)
  self.m_panel:FindChild("Group_BtnAutto"):SetActive(self.isSetting)
  self.m_panel:FindChild("Btn_Cancel"):SetActive(self.isSetting)
end
def.method().UpdateBasePropPrefab = function(self)
  local propRoot = self.m_panel:FindChild("Grid_JDPlan")
  local pet = PetMgr:GetPet(self.petId)
  local unusedNum = PetAssignPropMgr:GetUnusedPrefabPointNum(self.petId)
  for i, v in ipairs(propNameMap) do
    local addedProp = pet.assignPropScheme:GetAutoAssigning()[v]
    local labelName = string.format("Label_JDPlan_Num0%d", i)
    local label_prop = propRoot:FindChild(labelName):GetComponent("UILabel")
    label_prop:set_text(addedProp)
    local button_Minus = propRoot:FindDirect(string.format("Label_JDPlan_Attribute%02d/Btn_JDPlan_Minus%02d", i, i))
    if button_Minus == nil then
      button_Minus = propRoot:FindDirect(string.format("Label_JDPlan_Attribute%d/Btn_JDPlan_Minus%02d", i, i))
    end
    if addedProp > 0 then
      button_Minus:SetActive(true)
    else
      button_Minus:SetActive(false)
      if button_Minus.name == self.lastPressedId then
        AssignPointHelper.Instance():StopPressTimer()
      end
    end
    local button_Add = propRoot:FindDirect(string.format("Label_JDPlan_Attribute%02d/Btn_JDPlan_Add%02d", i, i))
    if button_Add == nil then
      button_Add = propRoot:FindDirect(string.format("Label_JDPlan_Attribute%d/Btn_JDPlan_Add%02d", i, i))
    end
    if unusedNum > 0 then
      button_Add:SetActive(true)
    else
      if button_Add.name == self.lastPressedId then
        AssignPointHelper.Instance():StopPressTimer()
      end
      button_Add:SetActive(false)
    end
  end
  self.m_panel:FindChild("Label_JDPlan_LatentNum"):GetComponent("UILabel"):set_text(unusedNum)
end
def.method().UpdateBasePropAssigned = function(self)
  local propRoot = self.m_panel:FindChild("Grid_JDPlan")
  local pet = PetMgr:GetPet(self.petId)
  local unusedNum = PetAssignPropMgr:GetUnusedPotentialPointNum(self.petId)
  for i, v in ipairs(propNameMap) do
    local baseProp = pet.baseProp[v]
    local addedProp = pet.assignPropScheme:GetManualAssigning()[v]
    local labelName = string.format("Label_JDPlan_Num0%d", i)
    local label_prop = propRoot:FindChild(labelName):GetComponent("UILabel")
    local button_Minus = propRoot:FindDirect(string.format("Label_JDPlan_Attribute%02d/Btn_JDPlan_Minus%02d", i, i))
    if button_Minus == nil then
      button_Minus = propRoot:FindDirect(string.format("Label_JDPlan_Attribute%d/Btn_JDPlan_Minus%02d", i, i))
    end
    if addedProp > 0 then
      label_prop:set_text(string.format(textRes.Pet[7], baseProp, addedProp))
      button_Minus:SetActive(true)
    else
      label_prop:set_text(baseProp)
      button_Minus:SetActive(false)
      if button_Minus.name == self.lastPressedId then
        AssignPointHelper.Instance():StopPressTimer()
      end
    end
    local button_Add = propRoot:FindDirect(string.format("Label_JDPlan_Attribute%02d/Btn_JDPlan_Add%02d", i, i))
    if button_Add == nil then
      button_Add = propRoot:FindDirect(string.format("Label_JDPlan_Attribute%d/Btn_JDPlan_Add%02d", i, i))
    end
    if unusedNum > 0 then
      button_Add:SetActive(true)
    else
      button_Add:SetActive(false)
      if button_Add.name == self.lastPressedId then
        AssignPointHelper.Instance():StopPressTimer()
      end
    end
  end
  self.m_panel:FindChild("Label_JDPlan_LatentNum"):GetComponent("UILabel"):set_text(unusedNum)
end
def.method().UpdateSecondProp = function(self)
  local prop2Root = self.m_panel:FindChild("Grid_JD_Attribute")
  local pet = PetMgr:GetPet(self.petId)
  for i, v in ipairs(prop2NameMap) do
    local secondProp = pet.secondProp[v]
    local addedProp = pet.assignPropScheme:GetPreviewedSecondProp()[v]
    local labelName = string.format("Label_JD_AttributeNum0%d", i)
    local label_prop = prop2Root:FindChild(labelName):GetComponent("UILabel")
    if addedProp > 0 then
      label_prop:set_text(string.format(textRes.Pet[7], secondProp, addedProp))
    else
      label_prop:set_text(secondProp)
    end
  end
end
def.method("boolean").SetAutoAssignToggleState = function(self, state)
  self.m_panel:FindChild("Btn_JDPlan_UnSelectUse01"):GetComponent("UIToggle"):set_isChecked(state)
end
def.method().Clear = function(self)
end
def.static("table", "table").OnSaveAssignPrefabSuccess = function()
  local self = instance
  self.isSetting = false
  self:UpdateBaseProp()
  Toast(textRes.Pet[8])
end
def.static("table", "table").OnPetInfoUpdate = function()
  local self = instance
  local pet = PetMgr:GetPet(self.petId)
  if self.isEnableAutoAssign ~= pet.assignPropScheme.isEnableAutoAssign then
    if pet.assignPropScheme.isEnableAutoAssign then
      Toast(textRes.Pet[92])
    else
      Toast(textRes.Pet[93])
    end
  end
  self:Fill()
end
def.method().OnResetPropButtonClick = function(self)
  local pet = PetMgr:GetPet(self.petId)
  if pet == nil then
    return
  end
  if not pet.isCanResetProp then
    Toast(textRes.Pet[68])
    return
  end
  local itemId = PetUtility.Instance():GetPetConstants("PET_RESET_PROP_ITEM_ID")
  local ItemModule = require("Main.Item.ItemModule")
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local USE_ITEM_NUM = 1
  local itemType = require("consts.mzm.gsp.item.confbean.ItemType").PET_RESET_ITEM
  local items = ItemModule.Instance():GetItemsByItemType(ItemModule.BAG, itemType)
  local count = 0
  for k, v in pairs(items) do
    count = count + v.number
  end
  local itemNum = count
  local desc = textRes.Pet[34]
  local title, extendItemId, itemNeed = textRes.Pet[33], itemId, USE_ITEM_NUM
  local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
  ItemConsumeHelper.Instance():ShowItemConsume(title, desc, extendItemId, itemNeed, function(select)
    local function ResetPoint(extraParams)
      PetAssignPropMgr:ResetPotentialPoint(self.petId, itemNum)
    end
    if select < 0 then
    elseif select == 0 then
      ResetPoint({isYuanBaoBuZu = false})
    else
      ResetPoint({isYuanBaoBuZu = true})
    end
  end)
end
def.method().OnTipsBtnClicked = function(self)
  local tipId = require("Main.Pet.PetModule").PET_ASSIGN_PROP_TIP_ID
  require("GUI.GUIUtils").ShowHoverTip(tipId)
end
return PetAssignPropPanel.Commit()
