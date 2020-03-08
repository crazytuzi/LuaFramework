local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local HeroAssignPropPanel = Lplus.Extend(ECPanelBase, "HeroAssignPropPanel")
local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr")
local HeroSecondProp = Lplus.ForwardDeclare("HeroSecondProp")
local HeroExtraProp = Lplus.ForwardDeclare("HeroExtraProp")
local HeroUtility = require("Main.Hero.HeroUtility")
local AssignPointHelper = require("Main.Common.AssignPointHelper")
local propNameMap = {
  "con",
  "spi",
  "str",
  "sta",
  "dex"
}
local def = HeroAssignPropPanel.define
def.field("boolean").isSetting = false
def.field("number").selectedSchemeIndex = 0
def.field("number").incPropTime = 0
def.field("number").decPropTime = 0
def.field("number").pressedTime = 0
def.field("string").lastPressedId = ""
def.field("string").incPropButtonId = ""
def.field("string").decPropButtonId = ""
def.field("number").digitalEntered = 0
def.field("boolean").isEnteredDigital = false
def.field("number").preBaseValue = 0
def.field("userdata").m_node = nil
def.field("table").uiObjs = nil
local instance
def.static("=>", HeroAssignPropPanel).Instance = function()
  if instance == nil then
    instance = HeroAssignPropPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_HERO_ASSIGN_PROP_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_PROP, HeroAssignPropPanel.OnSyncHeroProp)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SAVE_ASSIGN_RROP_SETTING_SUCCESS, HeroAssignPropPanel.OnSuccessSaveAutoAssignPropSetting)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SAVE_AUTO_ASSIGN_STATE_SUCCESS, HeroAssignPropPanel.OnSuccessSaveAutoAssignState)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SWITCH_ASSIGN_PROP_SCHEME_SUCCESS, HeroAssignPropPanel.OnSuccessSwitchScheme)
  AssignPointHelper.Instance():RegisterCallbackFuncs({
    OnContinuallyClick = HeroAssignPropPanel.OnContinuallyClick,
    OnButtonCalled = HeroAssignPropPanel.OnButtonCalled
  })
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SYNC_HERO_PROP, HeroAssignPropPanel.OnSyncHeroProp)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SAVE_ASSIGN_RROP_SETTING_SUCCESS, HeroAssignPropPanel.OnSuccessSaveAutoAssignPropSetting)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SAVE_AUTO_ASSIGN_STATE_SUCCESS, HeroAssignPropPanel.OnSuccessSaveAutoAssignState)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.SWITCH_ASSIGN_PROP_SCHEME_SUCCESS, HeroAssignPropPanel.OnSuccessSwitchScheme)
  self:Clear()
end
def.method().InitUI = function(self)
  self.m_node = self.m_panel:FindDirect("Img_JD")
  self.uiObjs = {}
  self.uiObjs.Img_JD_BgAttribute0 = self.m_node:FindDirect("Img_JD_BgAttribute0")
  self.uiObjs.Btn_OpenPlan = self.uiObjs.Img_JD_BgAttribute0:FindDirect("Btn_OpenPlan")
  self.uiObjs.Btn_SelectPlan = self.uiObjs.Img_JD_BgAttribute0:FindDirect("Btn_SelectPlan")
  self.uiObjs.Grid_JD_Attribute = self.uiObjs.Img_JD_BgAttribute0:FindDirect("Grid_JD_Attribute")
  self.uiObjs.Label_Opened = self.uiObjs.Img_JD_BgAttribute0:FindDirect("Label_Opened")
  self.uiObjs.Img_JD_Plan = self.m_node:FindDirect("Img_JD_Plan")
  self.uiObjs.Img_JD_BgPlan0 = self.uiObjs.Img_JD_Plan:FindDirect("Img_JD_BgPlan0")
  self.uiObjs.Label_JDPlan_Latent = self.uiObjs.Img_JD_Plan:FindDirect("Label_JDPlan_Latent")
  self.uiObjs.Group_BtnAdd = self.uiObjs.Img_JD_Plan:FindDirect("Group_BtnAdd")
  self.uiObjs.Group_BtnSettle = self.uiObjs.Img_JD_Plan:FindDirect("Group_BtnSettle")
  self.lastPressedId = ""
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.m_node = nil
  AssignPointHelper.Instance():StopPressTimer()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    self:DestroyPanel()
  elseif id == "Modal" then
    self:DestroyPanel()
  elseif string.sub(id, 1, -3) == "Btn_JDPlan_Add" then
    self:OnIncPropButtonClick(id)
  elseif string.sub(id, 1, -3) == "Btn_JDPlan_Minus" then
    self:OnDecPropButtonClick(id)
  elseif id == "Btn_JDPlanAdd_Wash" then
    self:OnRestPropButtonClick(id)
  elseif id == "Btn_JDPlanAdd_Confirm" then
    self:OnConfirmAssignButtonClick(id)
  elseif id == "Btn_JDPlan_UnSelectUse01" then
    self:OnIsEnableAutoAssignCheck(id)
  elseif string.sub(id, 1, -3) == "Tap_JD_Plan" then
    self:OnSchemeSelectButtonClick(id)
  elseif id == "Btn_OpenPlan" then
    self:OnEnbaleSchemeButtonClick()
  elseif id == "Btn_JDPlan_Settle" then
    self:OnSettingButtonClick(id)
  elseif id == "Btn_JDPlanSettle_Back" then
    self:OnSettingBackButtonClick(id)
  elseif id == "Btn_JDPlanSettle_Clear" then
    self:OnSettingClearButtonClick(id)
  elseif id == "Btn_JDPlanSettle_Save" then
    self:OnSettingSaveButtonClick(id)
  elseif string.sub(id, 1, 16) == "Img_JDPlan_BgNum" then
    self:OnBasePropValueClick(id)
  elseif id == "Btn_JDPlanAdd_Recommend" then
    self:OnRecommandAssignPropButtonClick()
  elseif id == "Btn_SelectPlan" then
    self:OnPlanSelectButtonClicked()
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
def.method("string", "string", "number").onSelect = function(self, id, selected, index)
  print("onSelect", id, selected, index)
  local schemeId = index
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  local unlockLevel = HeroAssignPointMgr.Instance():GetSchemeUnlockLevel(schemeId)
  if unlockLevel > heroProp.level then
    local schemeOrderName = textRes.Hero[300 + schemeId + 1]
    Toast(string.format(textRes.Hero[17], unlockLevel, schemeOrderName))
  else
    if self.selectedSchemeIndex ~= schemeId then
      local scheme = HeroAssignPointMgr.Instance():GetAssignPointScheme(self.selectedSchemeIndex)
      if scheme then
        scheme:Clear()
      end
    end
    self:SetPopupButtonIndex(index)
    self:SelectScheme(schemeId)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    self:OnHide()
    return
  end
  self:Fill(-1)
end
def.method().OnHide = function(self)
  self:ClearAssigningData()
end
def.static("table", "table").OnSyncHeroProp = function(params, context)
  instance:Fill(-1)
end
def.method("string").OnIncPropButtonClick = function(self, id)
  AssignPointHelper.Instance():OnButtonClick(id)
  self:OnIncPropButtonCalled(id)
end
def.method("string").OnIncPropButtonCalled = function(self, id)
  local num = tonumber(string.sub(id, -1, -1))
  local propNameMap = {
    "con",
    "spi",
    "str",
    "sta",
    "dex"
  }
  local propName = propNameMap[num]
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  if not self.isSetting then
    HeroAssignPointMgr.Instance():IncBaseProp(enabledIndex, propName)
    self:UpdateSecondProp()
  else
    HeroAssignPointMgr.Instance():IncBasePropSetting(enabledIndex, propName)
  end
  self:UpdateBaseProp()
end
def.method("string").OnDecPropButtonClick = function(self, id)
  AssignPointHelper.Instance():OnButtonClick(id)
  self:OnDecPropButtonCalled(id)
end
def.method("string").OnDecPropButtonCalled = function(self, id)
  local num = tonumber(string.sub(id, -1, -1))
  local propNameMap = {
    "con",
    "spi",
    "str",
    "sta",
    "dex"
  }
  local propName = propNameMap[num]
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  if not self.isSetting then
    HeroAssignPointMgr.Instance():DecBaseProp(enabledIndex, propName)
    self:UpdateSecondProp()
  else
    HeroAssignPointMgr.Instance():DecBasePropSetting(enabledIndex, propName)
  end
  self:UpdateBaseProp()
end
def.method("string").OnBasePropValueClick = function(self, id)
  local selectedIndex = self.selectedSchemeIndex
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  local isUnlock = HeroAssignPointMgr.Instance():IsUnlock()
  if selectedIndex ~= enabledIndex or not isUnlock then
    return
  end
  local scheme = HeroAssignPointMgr.Instance():GetAssignPointScheme(selectedIndex)
  local num = tonumber(string.sub(id, -1, -1))
  local propName = propNameMap[num]
  local availablePoint = 0
  if not self.isSetting then
    self.preBaseValue = scheme:GetManualAssigning()[propName]
    availablePoint = scheme.potentialPoint - scheme.manualAssignedPoint
  else
    self.preBaseValue = scheme.autoAssigning[propName]
    availablePoint = scheme.autoAssignPointLimit - scheme.autoAssignedPoint
  end
  if self.preBaseValue == 0 and availablePoint == 0 then
    return
  end
  self.digitalEntered = 0
  self.isEnteredDigital = false
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():ShowPanelEx(-1, HeroAssignPropPanel.OnDigitalKeyboardCallback, {self = self, id = id})
  CommonDigitalKeyboard.Instance():SetPos(-290, 0)
end
def.method("string").OnRestPropButtonClick = function(self, id)
  local assignPropMinLevel = HeroUtility.Instance():GetRoleCommonConsts("ADD_POTEN_FUNC_LEVEL")
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  if assignPropMinLevel > heroProp.level then
    Toast(string.format(textRes.Hero[14], assignPropMinLevel))
    return
  end
  local FightMgr = require("Main.Fight.FightMgr")
  if FightMgr.Instance().isInFight then
    Toast(textRes.Hero[29])
    return
  end
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  local scheme = HeroAssignPointMgr.Instance():GetAssignPointScheme(enabledIndex)
  if not scheme.isCanRefreshProp then
    Toast(textRes.Hero[22])
    return
  end
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local itemId = HeroUtility.Instance():GetRoleCommonConsts("RESET_POINT_ITEM_TYPE_ID")
  local ItemModule = require("Main.Item.ItemModule")
  local itemNum = ItemModule.Instance():GetItemCountById(itemId)
  local useItemNum = 1
  local desc = textRes.Hero[11]
  local title, extendItemId, itemNeed = textRes.Hero[48], itemId, useItemNum
  local ItemConsumeHelper = require("Main.Item.ItemConsumeHelper")
  ItemConsumeHelper.Instance():ShowItemConsume(title, desc, extendItemId, itemNeed, function(select)
    local function ResetPoint(extraParams)
      local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
      HeroAssignPointMgr.Instance():ResetAssignedPoint(enabledIndex, extraParams)
    end
    if select < 0 then
    elseif select == 0 then
      ResetPoint({isYuanBaoBuZu = false})
    else
      ResetPoint({isYuanBaoBuZu = true})
    end
  end)
end
def.method("string").OnConfirmAssignButtonClick = function(self, id)
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  HeroAssignPointMgr.Instance():SaveManualAssign(enabledIndex)
end
def.method("string").OnIsEnableAutoAssignCheck = function(self, id)
  local ECMSDK = require("ProxySDK.ECMSDK")
  local toggle_isAuto = self.m_node:FindDirect("Img_JD_Plan/Group_BtnAdd/Btn_JDPlan_UnSelectUse01"):GetComponent("UIToggle")
  local isAvailable = self:CheckIsAssignPointAvailable()
  if not isAvailable then
    toggle_isAuto:set_value(true)
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.AUTOADDPOINT, {1})
    return
  end
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  if HeroAssignPointMgr.Instance():GetUnusedAutoAssignPointAmount(enabledIndex) > 0 then
    Toast(textRes.Hero[59])
    toggle_isAuto:set_value(false)
    ECMSDK.SendTLogToServer(_G.TLOGTYPE.AUTOADDPOINT, {2})
    require("Main.Hero.ui.AutoAssignPropSettingPanel").Instance():ShowPanel()
    return
  end
  local function enableAutoAssign(isEnable)
    local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
    HeroAssignPointMgr.Instance():EnableAutoAssignPoint(enabledIndex, isEnable)
  end
  local isAuto = toggle_isAuto:get_value()
  if isAuto then
    local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
    CommonConfirmDlg.ShowConfirm(textRes.Hero[42], textRes.Hero[45], function(s)
      if s == 1 then
        enableAutoAssign(true)
      else
        toggle_isAuto:set_value(false)
        ECMSDK.SendTLogToServer(_G.TLOGTYPE.AUTOADDPOINT, {2})
      end
    end, nil)
  else
    enableAutoAssign(false)
  end
end
def.method("string").OnSchemeSelectButtonClick = function(self, id)
  local num = tonumber(string.sub(id, -1, -1))
  local schemeId = num - 1
  if self.selectedSchemeIndex ~= schemeId then
    local scheme = HeroAssignPointMgr.Instance():GetAssignPointScheme(self.selectedSchemeIndex)
    if scheme then
      scheme:Clear()
    end
  end
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  local unlockLevel = HeroAssignPointMgr.Instance():GetSchemeUnlockLevel(schemeId)
  if unlockLevel > heroProp.level then
    local schemeUIIndex = self.selectedSchemeIndex + 1
    local schemeOrderName = textRes.Hero[300 + num]
    Toast(string.format(textRes.Hero[17], unlockLevel, schemeOrderName))
  else
    self.selectedSchemeIndex = schemeId
    self:Fill(schemeId)
  end
end
def.method("number").SelectScheme = function(self, schemeId)
  if self.selectedSchemeIndex ~= schemeId then
    local scheme = HeroAssignPointMgr.Instance():GetAssignPointScheme(self.selectedSchemeIndex)
    if scheme then
      scheme:Clear()
    end
  end
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  local unlockLevel = HeroAssignPointMgr.Instance():GetSchemeUnlockLevel(schemeId)
  if unlockLevel > heroProp.level then
    local schemeUIIndex = self.selectedSchemeIndex + 1
    local schemeOrderName = textRes.Hero[300 + num]
    Toast(string.format(textRes.Hero[17], unlockLevel, schemeOrderName))
  else
    self.selectedSchemeIndex = schemeId
    self:Fill(schemeId)
  end
end
def.method().OnEnbaleSchemeButtonClick = function(self)
  local ui_Img_JD_Plan = self.m_node:FindDirect("Img_JD_Plan")
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  local times = HeroPropMgr.Instance().schemeSwitchTimes
  times = times + 1
  local swicthBaseCost = HeroUtility.Instance():GetRoleCommonConsts("SWITCH_PROP_SYS_COST")
  local neededSilverMoney = times * swicthBaseCost
  local message
  if _G.IsCrossingServer() then
    neededSilverMoney = 0
    message = textRes.Hero[64]
  elseif times >= 2 then
    message = string.format(textRes.Hero[4], neededSilverMoney)
  else
    neededSilverMoney = 0
    message = textRes.Hero[5]
  end
  CommonConfirmDlg.ShowConfirm("", message, HeroAssignPropPanel.EnbaleSchemeConfirmCallback, {neededSilverMoney = neededSilverMoney})
end
def.method("string").OnSettingButtonClick = function(self, id)
  local isAvailable = self:CheckIsAssignPointAvailable()
  if not isAvailable then
    return
  end
  require("Main.Hero.ui.AutoAssignPropSettingPanel").Instance():ShowPanel()
end
def.method("string").OnSettingBackButtonClick = function(self, id)
  self.isSetting = false
  local Label_Detail = self.m_node:FindDirect("Img_JD_Plan/Img_JD_BgPlan0/Label_Detail")
  Label_Detail:GetComponent("UILabel").text = textRes.Hero[41]
  self.m_node:FindDirect("Img_JD_Plan/Group_BtnSettle"):SetActive(false)
  self.m_node:FindDirect("Img_JD_Plan/Group_BtnAdd"):SetActive(true)
  local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  local enabledIndex = HeroAssignPointMgr:GetEnabledSchemeIndex()
  HeroAssignPointMgr:ClearChanges(enabledIndex)
  self:UpdateBaseProp()
end
def.method("string").OnSettingClearButtonClick = function(self, id)
  local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  local enabledIndex = HeroAssignPointMgr:GetEnabledSchemeIndex()
  HeroAssignPointMgr:ClearAutoAssignSetting(enabledIndex)
  self:UpdateBaseProp()
end
def.method("string").OnSettingSaveButtonClick = function(self, id)
  local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  local enabledIndex = HeroAssignPointMgr:GetEnabledSchemeIndex()
  HeroAssignPointMgr:SaveAutoAssignSetting(enabledIndex)
end
def.static("number", "table").EnbaleSchemeConfirmCallback = function(state, tag)
  if state == 0 then
    return
  end
  local ItemModule = require("Main.Item.ItemModule")
  local silverMoney = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_SILVER)
  if silverMoney:lt(tag.neededSilverMoney) then
    Toast(textRes.Common[13])
    return
  end
  local self = instance
  local schemeId = self.uiObjs.Btn_SelectPlan:GetComponent("UIPopupButton").value
  require("Main.Hero.mgr.HeroAssignPointMgr").Instance():EnableAssignPointScheme(schemeId)
end
def.method("number").SetToggledSchemeTap = function(self, index)
end
def.method("number").Fill = function(self, schemeId)
  self.isSetting = false
  local Label_Detail = self.m_node:FindDirect("Img_JD_Plan/Img_JD_BgPlan0/Label_Detail")
  Label_Detail:GetComponent("UILabel").text = textRes.Hero[41]
  self:UpdateSecondProp()
  local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  local enabledIndex = HeroAssignPointMgr:GetEnabledSchemeIndex()
  if schemeId == -1 then
    self.selectedSchemeIndex = enabledIndex
    self:ClearAssigningData()
    self:UpdateSecondProp()
  end
  local popupIndex = self.selectedSchemeIndex
  self:SetPopupButtonIndex(popupIndex)
  local scheme = HeroAssignPointMgr:GetAssignPointScheme(self.selectedSchemeIndex)
  local toggle_isauto = self.uiObjs.Group_BtnAdd:FindDirect("Btn_JDPlan_UnSelectUse01"):GetComponent("UIToggle")
  toggle_isauto:set_value(scheme.isEnableAutoAssign)
  self.uiObjs.Group_BtnSettle:SetActive(false)
  self.uiObjs.Group_BtnAdd:SetActive(true)
  self.uiObjs.Label_Opened:SetActive(true)
  self.uiObjs.Btn_OpenPlan:SetActive(false)
  self:UpdateBaseProp()
end
def.method().UpdateBaseProp = function(self)
  local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  local selectedIndex = self.selectedSchemeIndex
  local enabledIndex = HeroAssignPointMgr:GetEnabledSchemeIndex()
  local scheme = HeroAssignPointMgr:GetAssignPointScheme(selectedIndex)
  local ui_Img_JD_Plan = self.uiObjs.Img_JD_Plan
  local grid_baseProp = ui_Img_JD_Plan:FindDirect("Img_JD_BgPlan0/Grid_JDPlan")
  local label_potential = ui_Img_JD_Plan:FindDirect("Label_JDPlan_Latent/Label_JDPlan_LatentNum"):GetComponent("UILabel")
  local btn_confirmAssign = ui_Img_JD_Plan:FindDirect("Group_BtnAdd/Btn_JDPlanAdd_Confirm"):GetComponent("UIButton")
  btn_confirmAssign:set_isEnabled(false)
  if not self.isSetting then
    self:SetBasePropValue(scheme, selectedIndex)
    label_potential:set_text(scheme.potentialPoint - scheme.manualAssignedPoint)
  else
    self:SetBasePropSettingValue(scheme, selectedIndex)
    label_potential:set_text(scheme.autoAssignPointLimit - scheme.autoAssignedPoint)
  end
  if selectedIndex ~= enabledIndex then
    self:SetUnEnableState()
  end
end
def.method(HeroSecondProp).SetSecondProp = function(self, secondProp)
  local prop2 = self.m_node:FindDirect("Img_JD_BgAttribute0/Grid_JD_Attribute")
  local propTable = {
    secondProp.maxHp,
    secondProp.maxMp,
    secondProp.phyAtk,
    secondProp.magAtk,
    secondProp.phyDef,
    secondProp.magDef,
    secondProp.speed
  }
  for i, v in ipairs(propTable) do
    local labelName = string.format("Img_JD_BgAttribute0%d/Label_JD_Attribute0%d/Label_JD_AttributeNum0%d", i, i, i)
    local label_prop = prop2:FindDirect(labelName):GetComponent("UILabel")
    label_prop:set_text(v)
  end
end
def.method().UpdateSecondProp = function(self)
  local prop = Lplus.ForwardDeclare("HeroModule").Instance():GetHeroProp()
  local prop2NameMap = {
    "maxHp",
    "maxMp",
    "phyAtk",
    "magAtk",
    "phyDef",
    "magDef",
    "speed"
  }
  local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  local enabledIndex = HeroAssignPointMgr:GetEnabledSchemeIndex()
  local scheme = HeroAssignPointMgr:GetAssignPointScheme(enabledIndex)
  local prop2Root = self.m_node:FindDirect("Img_JD_BgAttribute0/Grid_JD_Attribute")
  for i, v in ipairs(prop2NameMap) do
    local secondProp = prop.secondProp[v]
    local addedProp = scheme:GetPreviewedSecondProp()[v]
    local labelName = string.format("Img_JD_BgAttribute0%d/Label_JD_Attribute0%d/Label_JD_AttributeNum0%d", i, i, i)
    local label_prop = prop2Root:FindDirect(labelName):GetComponent("UILabel")
    if addedProp > 0 then
      label_prop:set_text(string.format(textRes.Common[25], secondProp, addedProp))
    else
      label_prop:set_text(secondProp)
    end
  end
end
def.method("number").SetPotentialPoint = function(self, value)
  local objectName = "Img_JD_Plan/Label_JDPlan_Latent/Label_JDPlan_LatentNum"
  local label_potential = self.m_node:FindDirect(objectName):GetComponent("UILabel")
  label_potential:set_text(value)
end
def.method().SetUnEnableState = function(self)
  local ui_Img_JD_Plan = self.m_node:FindDirect("Img_JD_Plan")
  local grid_baseProp = ui_Img_JD_Plan:FindDirect("Img_JD_BgPlan0/Grid_JDPlan")
  ui_Img_JD_Plan:FindDirect("Group_BtnSettle"):SetActive(false)
  ui_Img_JD_Plan:FindDirect("Group_BtnAdd"):SetActive(false)
  for i, v in ipairs(propNameMap) do
    local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Minus0%d", i, i)
    local button_prop = grid_baseProp:FindDirect(ctrlName)
    button_prop:SetActive(false)
    local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Add0%d", i, i)
    local button_prop = grid_baseProp:FindDirect(ctrlName)
    button_prop:SetActive(false)
  end
  self.uiObjs.Label_Opened:SetActive(false)
  self.uiObjs.Btn_OpenPlan:SetActive(true)
end
def.method("table", "number").SetBasePropValue = function(self, scheme, selectedIndex)
  local ui_Img_JD_Plan = self.m_node:FindDirect("Img_JD_Plan")
  local btn_confirmAssign = ui_Img_JD_Plan:FindDirect("Group_BtnAdd/Btn_JDPlanAdd_Confirm"):GetComponent("UIButton")
  local grid_baseProp = ui_Img_JD_Plan:FindDirect("Img_JD_BgPlan0/Grid_JDPlan")
  for i, v in ipairs(propNameMap) do
    local ctrlName = string.format("Label_JDPlan_Attribute0%d/Img_JDPlan_BgNum0%d/Label_JDPlan_Num0%d", i, i, i)
    local label_prop = grid_baseProp:FindDirect(ctrlName):GetComponent("UILabel")
    local baseProp = scheme.totalBaseProp[v]
    local addedProp = scheme:GetManualAssigning()[v]
    if addedProp > 0 then
      label_prop:set_text(string.format(textRes.Common[25], baseProp, addedProp))
      local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Minus0%d", i, i)
      local button_prop = grid_baseProp:FindDirect(ctrlName)
      button_prop:SetActive(true)
      btn_confirmAssign:set_isEnabled(true)
    else
      label_prop:set_text(baseProp)
      local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Minus0%d", i, i)
      local button_prop = grid_baseProp:FindDirect(ctrlName)
      button_prop:SetActive(false)
      if button_prop.name == self.lastPressedId then
        AssignPointHelper.Instance():StopPressTimer()
      end
    end
    local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Add0%d", i, i)
    local button_prop = grid_baseProp:FindDirect(ctrlName)
    if 0 >= HeroAssignPointMgr.Instance():GetUnusedPotentialPointAmount(selectedIndex) then
      button_prop:SetActive(false)
      if button_prop.name == self.lastPressedId then
        AssignPointHelper.Instance():StopPressTimer()
      end
    else
      button_prop:SetActive(true)
    end
  end
end
def.method("table", "number").SetBasePropSettingValue = function(self, scheme, selectedIndex)
  local ui_Img_JD_Plan = self.m_node:FindDirect("Img_JD_Plan")
  local grid_baseProp = ui_Img_JD_Plan:FindDirect("Img_JD_BgPlan0/Grid_JDPlan")
  for i, v in ipairs(propNameMap) do
    local ctrlName = string.format("Label_JDPlan_Attribute0%d/Img_JDPlan_BgNum0%d/Label_JDPlan_Num0%d", i, i, i)
    local label_prop = grid_baseProp:FindDirect(ctrlName):GetComponent("UILabel")
    local addedProp = scheme:GetAutoAssigning()[v]
    if addedProp > 0 then
      local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Minus0%d", i, i)
      local button_prop = grid_baseProp:FindDirect(ctrlName)
      button_prop:SetActive(true)
    else
      local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Minus0%d", i, i)
      local button_prop = grid_baseProp:FindDirect(ctrlName)
      button_prop:SetActive(false)
      if button_prop.name == self.lastPressedId then
        AssignPointHelper.Instance():StopPressTimer()
      end
    end
    local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Add0%d", i, i)
    local button_prop = grid_baseProp:FindDirect(ctrlName)
    if 0 >= HeroAssignPointMgr.Instance():GetUnusedAutoAssignPointAmount(selectedIndex) then
      button_prop:SetActive(false)
      if button_prop.name == self.lastPressedId then
        AssignPointHelper.Instance():StopPressTimer()
      end
    else
      button_prop:SetActive(true)
    end
    label_prop:set_text(addedProp)
  end
  local btn_saveSetting = ui_Img_JD_Plan:FindDirect("Group_BtnSettle/Btn_JDPlanSettle_Save"):GetComponent("UIButton")
  if HeroAssignPointMgr.Instance():GetUnusedAutoAssignPointAmount(selectedIndex) == 0 then
    btn_saveSetting:set_isEnabled(true)
  else
    btn_saveSetting:set_isEnabled(false)
  end
end
def.method("number").SetPopupButtonIndex = function(self, index)
  local uiPopupButton = self.uiObjs.Btn_SelectPlan:GetComponent("UIPopupButton")
  local selectedItem = uiPopupButton.items[index + 1]
  self.uiObjs.Btn_SelectPlan:FindDirect("Label"):GetComponent("UILabel").text = selectedItem
end
def.static("number", "table").OnDigitalKeyboardCallback = function(value, tag)
  local self = tag.self
  if self.m_panel == nil then
    return
  end
  local num = tonumber(string.sub(tag.id, -1, -1))
  local propName = propNameMap[num]
  local actualValue = self:UpdateEnteredValue(propName, value)
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():SetEnteredValue(actualValue)
end
def.static("table", "table").OnSuccessSaveAutoAssignPropSetting = function(params, context)
  local schemeId = params[1]
  local self = instance
  self:OnSettingBackButtonClick("none")
end
def.static("table", "table").OnSuccessSaveAutoAssignState = function(params, context)
  local schemeId = params[1]
  local self = instance
  local HeroAssignPointMgr = require("Main.Hero.mgr.HeroAssignPointMgr").Instance()
  local enabledIndex = HeroAssignPointMgr:GetEnabledSchemeIndex()
  schemeId = enabledIndex
  local scheme = HeroAssignPointMgr:GetAssignPointScheme(schemeId)
  local toggle_isauto = self.m_node:FindDirect("Img_JD_Plan/Group_BtnAdd/Btn_JDPlan_UnSelectUse01"):GetComponent("UIToggle")
  toggle_isauto:set_value(scheme.isEnableAutoAssign)
  if not scheme.isEnableAutoAssign then
    Toast(textRes.Hero[12])
  else
    local tmpPosition = {
      x = 0,
      y = 0,
      z = 0
    }
    require("GUI.CommonUITipsDlg").Instance():ShowDlgEx(string.format(textRes.Hero[15], scheme.autoAssigned.con, scheme.autoAssigned.spi, scheme.autoAssigned.str, scheme.autoAssigned.sta, scheme.autoAssigned.dex), tmpPosition, Alignment.Center, 3)
  end
end
def.static("table", "table").OnSuccessSwitchScheme = function(params, context)
  local schemeId = params[1]
  local showNum = schemeId + 1
  Toast(string.format(textRes.Hero[16], showNum))
end
def.method("string", "number", "=>", "number").UpdateEnteredValue = function(self, propName, value)
  local enabledIndex = HeroAssignPointMgr.Instance():GetEnabledSchemeIndex()
  local actualValue
  if not self.isSetting then
    actualValue = HeroAssignPointMgr.Instance():SetBaseProp(enabledIndex, propName, value)
    self:UpdateSecondProp()
  else
    actualValue = HeroAssignPointMgr.Instance():SetBasePropSetting(enabledIndex, propName, value)
  end
  self:UpdateBaseProp()
  return actualValue
end
def.method().ClearAssigningData = function(self)
  if self.selectedSchemeIndex ~= 0 then
    HeroAssignPointMgr.Instance():ClearManualAssign(self.selectedSchemeIndex)
  end
end
def.method().OnRecommandAssignPropButtonClick = function(self)
  local isAvailable = self:CheckIsAssignPointAvailable()
  if not isAvailable then
    return
  end
  require("Main.Hero.ui.PropRecommendPanel").Instance():ShowPanel()
end
def.method("table", "=>", "string").GetFormatRecommandAssignText = function(self, cfgList)
  local atrrNameMap = {
    [103] = "str",
    [104] = "spr",
    [105] = "con",
    [106] = "sta",
    [107] = "dex"
  }
  local textTable = {}
  for i, cfg in ipairs(cfgList) do
    local lineTextTable = {}
    table.insert(lineTextTable, string.format("%s    ", textRes.Common[21]))
    for k, v in pairs(atrrNameMap) do
      if cfg[v] > 0 then
        table.insert(lineTextTable, string.format("%d%s ", cfg[v], textRes.Hero[k]))
      end
    end
    local descTable = string.split(cfg.desc, "|")
    local descStr = table.concat(descTable, " ")
    table.insert(lineTextTable, descStr)
    local line = table.concat(lineTextTable, "")
    table.insert(textTable, line)
  end
  return table.concat(textTable, [[


]])
end
def.method("=>", "boolean").CheckIsAssignPointAvailable = function(self)
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  local assignPropMinLevel = HeroUtility.Instance():GetRoleCommonConsts("ADD_POTEN_FUNC_LEVEL")
  if assignPropMinLevel > heroProp.level then
    Toast(string.format(textRes.Hero[20], assignPropMinLevel))
    return false
  end
  return true
end
def.static("string").OnContinuallyClick = function(id)
  Toast(textRes.Hero[21])
end
def.static("string", "number").OnButtonCalled = function(id, type)
  local self = instance
  if self.uiObjs == nil then
    return
  end
  if type == AssignPointHelper.PressedButtonType.Inc then
    self:OnIncPropButtonCalled(id)
  elseif type == AssignPointHelper.PressedButtonType.Dec then
    self:OnDecPropButtonCalled(id)
  end
end
def.method().OnPlanSelectButtonClicked = function(self)
  self:UpdateDropdownButtonState()
end
def.method().OnTipsBtnClicked = function(self)
  local tipId = HeroUtility.Instance():GetRoleCommonConsts("PRO_TIP_CONTENT")
  require("GUI.GUIUtils").ShowHoverTip(tipId)
end
def.method().UpdateDropdownButtonState = function(self)
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  local DropdownList = self.uiObjs.Btn_SelectPlan:FindDirect("Drop-down List")
  for i = 1, DropdownList.transform.childCount do
    local child = DropdownList.transform:GetChild(i - 1)
    local childObj = child.gameObject
    local uiButton = childObj:GetComponent("UIButton")
    local Img_Lock = childObj:FindDirect("Img_Lock")
    local schemeId = i - 1
    local unlockLevel = HeroAssignPointMgr.Instance():GetSchemeUnlockLevel(schemeId)
    if unlockLevel > heroProp.level then
      Img_Lock:SetActive(true)
      uiButton.defaultColor = uiButton.disabledColor
      uiButton.hover = uiButton.disabledColor
    else
      Img_Lock:SetActive(false)
      uiButton:set_isEnabled(true)
    end
  end
end
return HeroAssignPropPanel.Commit()
