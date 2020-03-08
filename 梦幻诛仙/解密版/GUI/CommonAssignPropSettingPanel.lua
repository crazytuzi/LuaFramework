local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CommonAssignPropSettingPanel = Lplus.Extend(ECPanelBase, "CommonAssignPropSettingPanel")
local AssignPointHelper = require("Main.Common.AssignPointHelper")
local propNameMap = {
  "con",
  "spi",
  "str",
  "sta",
  "dex"
}
local GUIUtils = require("GUI.GUIUtils")
local def = CommonAssignPropSettingPanel.define
def.field("number").incPropTime = 0
def.field("number").decPropTime = 0
def.field("number").pressedTime = 0
def.field("string").lastPressedId = ""
def.field("string").incPropButtonId = ""
def.field("string").decPropButtonId = ""
def.field("number").digitalEntered = 0
def.field("boolean").isEnteredDigital = false
def.field("number").preBaseValue = 0
def.field("boolean").isEnableConfirm = false
def.field("userdata").m_node = nil
def.field("table").uiObjs = nil
def.field("table").scheme = nil
local AssignPointHelperInstance, instance
def.final("=>", CommonAssignPropSettingPanel).Instance = function()
  if instance == nil then
    instance = CommonAssignPropSettingPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.PREFAB_HERO_AUTO_ASSIGN_PROP_SETTING_PANEL, 2)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  instance = self
  self:InitUI()
  AssignPointHelperInstance = AssignPointHelper()
  AssignPointHelperInstance:RegisterCallbackFuncs({
    OnContinuallyClick = CommonAssignPropSettingPanel.OnContinuallyClick,
    OnButtonCalled = CommonAssignPropSettingPanel.OnButtonCalled
  })
end
def.override().OnDestroy = function(self)
  self:Clear()
end
def.method().InitUI = function(self)
  self.m_node = self.m_panel:FindDirect("Img_JD")
  self.uiObjs = {}
  self.uiObjs.Img_JD_Plan = self.m_node
  self.uiObjs.Img_JD_BgPlan0 = self.uiObjs.Img_JD_Plan:FindDirect("Img_JD_BgPlan0")
  self.uiObjs.Group_BtnSettle = self.uiObjs.Img_JD_Plan:FindDirect("Group_BtnSettle")
  self.lastPressedId = ""
end
def.method().Clear = function(self)
  self.uiObjs = nil
  self.m_node = nil
  AssignPointHelperInstance:StopPressTimer()
  AssignPointHelperInstance = nil
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
  elseif id == "Btn_JDPlanSettle_Clear" then
    self:OnSettingClearButtonClicked()
  elseif id == "Btn_JDPlanSettle_Save" then
    self:OnSettingSaveButtonClicked()
  elseif string.sub(id, 1, 16) == "Img_JDPlan_BgNum" then
    self:OnBasePropValueClick(id)
  elseif id == "Btn_JDPlanSettle__Recommend" then
    self:OnRecommendBtnClicked()
  end
end
def.method("string", "boolean").onPress = function(self, id, state)
  self.lastPressedId = id
  if string.sub(id, 1, -3) == "Btn_JDPlan_Add" then
    AssignPointHelperInstance:TogglePressedButtonTimer(id, AssignPointHelper.PressedButtonType.Inc, state)
  elseif string.sub(id, 1, -3) == "Btn_JDPlan_Minus" then
    AssignPointHelperInstance:TogglePressedButtonTimer(id, AssignPointHelper.PressedButtonType.Dec, state)
  end
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:Fill()
end
def.virtual("string").OnIncProp = function(self, propName)
end
def.virtual("string").OnDecProp = function(self, propName)
end
def.virtual().OnSettingClearButtonClicked = function(self)
end
def.virtual().OnSettingSaveButtonClicked = function(self)
  if not self.isEnableConfirm then
    Toast(textRes.Hero[44])
    return
  end
end
def.virtual().OnRecommendBtnClicked = function(self)
end
def.virtual("string", "number", "=>", "number").UpdateEnteredValue = function(self, propName, value)
  return value
end
def.method("string").OnIncPropButtonClick = function(self, id)
  AssignPointHelperInstance:OnButtonClick(id)
  self:OnIncPropButtonCalled(id)
end
def.method("string").OnIncPropButtonCalled = function(self, id)
  local num = tonumber(string.sub(id, -1, -1))
  local propName = propNameMap[num]
  self:OnIncProp(propName)
end
def.method("string").OnDecPropButtonClick = function(self, id)
  AssignPointHelperInstance:OnButtonClick(id)
  self:OnDecPropButtonCalled(id)
end
def.method("string").OnDecPropButtonCalled = function(self, id)
  local num = tonumber(string.sub(id, -1, -1))
  local propName = propNameMap[num]
  self:OnDecProp(propName)
end
def.method("string").OnBasePropValueClick = function(self, id)
  local num = tonumber(string.sub(id, -1, -1))
  local propName = propNameMap[num]
  local scheme = self.scheme
  local availablePoint = 0
  self.preBaseValue = scheme.autoAssigning[propName]
  availablePoint = scheme.autoAssignPointLimit - scheme.autoAssignedPoint
  if self.preBaseValue == 0 and availablePoint == 0 then
    return
  end
  self.digitalEntered = 0
  self.isEnteredDigital = false
  local CommonDigitalKeyboard = require("GUI.CommonDigitalKeyboard")
  CommonDigitalKeyboard.Instance():ShowPanelEx(-1, CommonAssignPropSettingPanel.OnDigitalKeyboardCallback, {self = self, id = id})
  CommonDigitalKeyboard.Instance():SetPos(-290, 0)
end
def.method().Fill = function(self)
  self:UpdateBaseProp()
end
def.virtual().UpdateBaseProp = function(self)
  self:EnableConfirm(false)
  local scheme = self.scheme
  self:SetBasePropSettingValue(scheme)
  local value = scheme.autoAssignPointLimit - scheme.autoAssignedPoint
  self:SetPotentialPoint(value)
end
def.method("number").SetPotentialPoint = function(self, value)
  local label_potential = self.uiObjs.Group_BtnSettle:FindDirect("Label_JDPlan_LeftPoint")
  local text = string.format(textRes.Hero[43], tostring(value))
  GUIUtils.SetText(label_potential, text)
end
def.method("boolean").EnableConfirm = function(self, isEnable)
  local uiButton = self.uiObjs.Group_BtnSettle:FindDirect("Btn_JDPlanSettle_Save"):GetComponent("UIButton")
  if isEnable then
    uiButton:ResetDefaultColor()
    uiButton.hover = uiButton.defaultColor
    uiButton.pressed = uiButton.defaultColor
  else
    uiButton.defaultColor = uiButton.disabledColor
    uiButton.hover = uiButton.disabledColor
    uiButton.pressed = uiButton.disabledColor
  end
  self.isEnableConfirm = isEnable
end
def.method("table").SetBasePropSettingValue = function(self, scheme)
  local grid_baseProp = self.uiObjs.Img_JD_BgPlan0:FindDirect("Grid_JDPlan")
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
        AssignPointHelperInstance:StopPressTimer()
      end
    end
    local ctrlName = string.format("Label_JDPlan_Attribute0%d/Btn_JDPlan_Add0%d", i, i)
    local button_prop = grid_baseProp:FindDirect(ctrlName)
    local unusedPoint = scheme.autoAssignPointLimit - scheme.autoAssignedPoint
    if unusedPoint <= 0 then
      button_prop:SetActive(false)
      if button_prop.name == self.lastPressedId then
        AssignPointHelperInstance:StopPressTimer()
      end
    else
      button_prop:SetActive(true)
    end
    label_prop:set_text(addedProp)
  end
  local unusedPoint = scheme.autoAssignPointLimit - scheme.autoAssignedPoint
  if unusedPoint == 0 then
    self:EnableConfirm(true)
  else
    self:EnableConfirm(false)
  end
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
return CommonAssignPropSettingPanel.Commit()
