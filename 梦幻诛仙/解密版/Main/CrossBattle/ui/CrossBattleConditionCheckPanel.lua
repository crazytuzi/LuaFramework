local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleConditionCheckPanel = Lplus.Extend(ECPanelBase, "CrossBattleConditionCheckPanel")
local GUIUtils = require("GUI.GUIUtils")
local def = CrossBattleConditionCheckPanel.define
def.field("table").uiObjs = nil
def.field("table").conditionDesc = nil
def.field("table").conditionStatus = nil
def.field("function").confirmCallback = nil
def.field("function").cancelCallback = nil
def.field("boolean").confirmAutoClose = false
local instance
def.static("=>", CrossBattleConditionCheckPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleConditionCheckPanel()
  end
  return instance
end
def.method("table", "table").ShowPanel = function(self, conditionDesc, initStatus)
  if self:IsShow() then
    return
  end
  self.conditionDesc = conditionDesc
  self.conditionStatus = initStatus
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_SELECTION_JOIN, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:InitCheckStatus()
  self:UpdateCheckStatus()
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.conditionDesc = nil
  self.conditionStatus = nil
  self.confirmCallback = nil
  self.cancelCallback = nil
  self.confirmAutoClose = false
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Group_Center = self.uiObjs.Img_Bg:FindDirect("Group_Center")
  self.uiObjs.ScrollView = self.uiObjs.Group_Center:FindDirect("Group_List/Scroll View")
  self.uiObjs.ConditionList = self.uiObjs.ScrollView:FindDirect("List_Member")
  self.uiObjs.Group_Bottom = self.uiObjs.Img_Bg:FindDirect("Group_Bottom")
  self.uiObjs.Btn_Join = self.uiObjs.Group_Bottom:FindDirect("Btn_Join")
end
def.method().InitCheckStatus = function(self)
  if not self:IsLoaded() then
    return
  end
  local uiList = self.uiObjs.ConditionList:GetComponent("UIList")
  uiList.itemCount = self.conditionDesc and #self.conditionDesc or 0
  uiList:Resize()
  local uiItems = uiList.children
  for i = 1, uiList.itemCount do
    local uiItem = uiItems[i]
    local condition = uiItem:FindDirect("Label_TermName")
    local Group_Result = uiItem:FindDirect("Group_Result")
    local Img_Right = Group_Result:FindDirect("Img_Right")
    local Img_Wrong = Group_Result:FindDirect("Img_Wrong")
    GUIUtils.SetText(condition, self.conditionDesc[i])
    GUIUtils.SetActive(Img_Right, false)
    GUIUtils.SetActive(Img_Wrong, true)
  end
  self.uiObjs.Btn_Join:GetComponent("UIButton"):set_isEnabled(false)
end
def.method().UpdateCheckStatus = function(self)
  if not self:IsLoaded() then
    return
  end
  if self.conditionStatus == nil then
    return
  end
  local uiList = self.uiObjs.ConditionList:GetComponent("UIList")
  local uiItems = uiList.children
  for i = 1, #uiItems do
    local uiItem = uiItems[i]
    local Group_Result = uiItem:FindDirect("Group_Result")
    local Img_Right = Group_Result:FindDirect("Img_Right")
    local Img_Wrong = Group_Result:FindDirect("Img_Wrong")
    local status = self.conditionStatus[i] or false
    GUIUtils.SetActive(Img_Right, status)
    GUIUtils.SetActive(Img_Wrong, not status)
  end
  local canJoin = true
  for i = 1, #self.conditionStatus do
    canJoin = canJoin and self.conditionStatus[i]
    if not canJoin then
      break
    end
  end
  self.uiObjs.Btn_Join:GetComponent("UIButton"):set_isEnabled(canJoin)
end
def.method("table").SetConditionCheckStatus = function(self, status)
  if not self:IsCreated() then
    return
  end
  self.conditionStatus = status
  self:UpdateCheckStatus()
end
def.method("function", "boolean").SetConfirmCallback = function(self, f, confirmAutoClose)
  self.confirmCallback = f
  self.confirmAutoClose = confirmAutoClose
end
def.method("function").SetCancelCallback = function(self, f)
  self.cancelCallback = f
end
def.method().HidePanel = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Quit" then
    self:OnBtnQuitClick()
  elseif id == "Btn_Join" then
    self:OnBtnConfirmClick()
  end
end
def.method().OnBtnQuitClick = function(self)
  if self.cancelCallback then
    self.cancelCallback()
  end
  self:HidePanel()
end
def.method().OnBtnConfirmClick = function(self)
  if not self.confirmCallback or self.confirmAutoClose then
    self:HidePanel()
  else
    self.confirmCallback()
  end
end
CrossBattleConditionCheckPanel.Commit()
return CrossBattleConditionCheckPanel
