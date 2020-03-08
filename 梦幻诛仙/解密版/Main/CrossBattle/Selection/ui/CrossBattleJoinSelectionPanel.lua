local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local CrossBattleJoinSelectionPanel = Lplus.Extend(ECPanelBase, "CrossBattleJoinSelectionPanel")
local GUIUtils = require("GUI.GUIUtils")
local CrossBattleSelectionData = require("Main.CrossBattle.Selection.data.CrossBattleSelectionData")
local def = CrossBattleJoinSelectionPanel.define
def.const("number").CHECK_CONDITION_NUM = 4
def.field("table").uiObjs = nil
local instance
def.static("=>", CrossBattleJoinSelectionPanel).Instance = function()
  if instance == nil then
    instance = CrossBattleJoinSelectionPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self:IsShow() then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_TEAM_PVP_CROSS_SELECTION_JOIN, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:ResetCheckStatus()
  self:UpdateCheckStatus()
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleSelection.Join_Condition_Update, CrossBattleJoinSelectionPanel.OnJoinConditionUpdate)
  Event.RegisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleSelection.Enter_Wating_Hall, CrossBattleJoinSelectionPanel.OnEnterWaitingHall)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleSelection.Join_Condition_Update, CrossBattleJoinSelectionPanel.OnJoinConditionUpdate)
  Event.UnregisterEvent(ModuleId.CROSS_BATTLE, gmodule.notifyId.CrossBattle.CrossBattleSelection.Enter_Wating_Hall, CrossBattleJoinSelectionPanel.OnEnterWaitingHall)
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
def.method().ResetCheckStatus = function(self)
  local uiList = self.uiObjs.ConditionList:GetComponent("UIList")
  uiList.itemCount = CrossBattleJoinSelectionPanel.CHECK_CONDITION_NUM
  uiList:Resize()
  local conditionDesc = {
    textRes.CrossBattle.CrossBattleSelection[1],
    textRes.CrossBattle.CrossBattleSelection[2],
    textRes.CrossBattle.CrossBattleSelection[3],
    textRes.CrossBattle.CrossBattleSelection[4]
  }
  local uiItems = uiList.children
  for i = 1, uiList.itemCount do
    local uiItem = uiItems[i]
    local condition = uiItem:FindDirect("Label_TermName")
    local Group_Result = uiItem:FindDirect("Group_Result")
    local Img_Right = Group_Result:FindDirect("Img_Right")
    local Img_Wrong = Group_Result:FindDirect("Img_Wrong")
    GUIUtils.SetText(condition, conditionDesc[i])
    GUIUtils.SetActive(Img_Right, false)
    GUIUtils.SetActive(Img_Wrong, true)
  end
  self.uiObjs.Btn_Join:GetComponent("UIButton"):set_isEnabled(false)
end
def.method().UpdateCheckStatus = function(self)
  local uiList = self.uiObjs.ConditionList:GetComponent("UIList")
  local conditionStatus = CrossBattleSelectionData.Instance():GetJoinConditionStatus()
  if conditionStatus == nil then
    return
  end
  local status = {
    conditionStatus.is_five_role_team,
    conditionStatus.is_in_one_corps,
    conditionStatus.is_can_take_part_in_selection,
    conditionStatus.is_role_same_with_sign_up
  }
  local uiItems = uiList.children
  for i = 1, CrossBattleJoinSelectionPanel.CHECK_CONDITION_NUM do
    local uiItem = uiItems[i]
    local Group_Result = uiItem:FindDirect("Group_Result")
    local Img_Right = Group_Result:FindDirect("Img_Right")
    local Img_Wrong = Group_Result:FindDirect("Img_Wrong")
    GUIUtils.SetActive(Img_Right, status[i])
    GUIUtils.SetActive(Img_Wrong, not status[i])
  end
  local canJoin = true
  for i = 1, CrossBattleJoinSelectionPanel.CHECK_CONDITION_NUM do
    canJoin = canJoin and status[i]
    if not canJoin then
      break
    end
  end
  self.uiObjs.Btn_Join:GetComponent("UIButton"):set_isEnabled(canJoin)
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Quit" then
    self:OnBtnQuitClick()
  elseif id == "Btn_Join" then
    self:OnBtnJoinClick()
  end
end
def.method().OnBtnQuitClick = function(self)
  self:DestroyPanel()
end
def.method().OnBtnJoinClick = function(self)
  local CrossBattleSelectionMgr = require("Main.CrossBattle.Selection.mgr.CrossBattleSelectionMgr")
  CrossBattleSelectionMgr.Instance():EnterCrossBattleSelectionWatingMap()
end
def.static("table", "table").OnJoinConditionUpdate = function(params, context)
  local self = instance
  self:UpdateCheckStatus()
end
def.static("table", "table").OnEnterWaitingHall = function(params, context)
  local self = instance
  self:DestroyPanel()
end
CrossBattleJoinSelectionPanel.Commit()
return CrossBattleJoinSelectionPanel
