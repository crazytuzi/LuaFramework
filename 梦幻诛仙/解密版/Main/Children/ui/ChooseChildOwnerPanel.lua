local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local ChooseChildOwnerPanel = Lplus.Extend(ECPanelBase, "ChooseChildOwnerPanel")
local GUIUtils = require("GUI.GUIUtils")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local def = ChooseChildOwnerPanel.define
local instance
def.field("table").uiObjs = nil
def.field("number").waitTimerId = 0
def.field("number").forceReadTimerId = 0
def.field("number").remainTime = 0
def.static("=>", ChooseChildOwnerPanel).Instance = function()
  if instance == nil then
    instance = ChooseChildOwnerPanel()
  end
  return instance
end
def.method().ShowPanel = function(self)
  if self.m_panel ~= nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_CHOOSE_BABY_NAME, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:UpdateInfo()
  self:ForceReadComment()
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHOOSE_CHILD_BELONG_RESULT, ChooseChildOwnerPanel.OnChooseChildBelongResult)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_LEAVE, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_UPGRADE_TO_CAPTION, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, ChooseChildOwnerPanel.OnTeamMemberInfoChanged)
end
def.override().OnDestroy = function(self)
  self.uiObjs = nil
  self.remainTime = 0
  self:DestroyTipsTimer()
  self:DestroyForceReadTimer()
  Event.UnregisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.CHOOSE_CHILD_BELONG_RESULT, ChooseChildOwnerPanel.OnChooseChildBelongResult)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_LEAVE, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_UPGRADE_TO_CAPTION, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, ChooseChildOwnerPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.UPDATE_TEAM_INFO, ChooseChildOwnerPanel.OnTeamMemberInfoChanged)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_Bg = self.m_panel:FindDirect("Img_Bg")
  self.uiObjs.Label_Tips = self.uiObjs.Img_Bg:FindDirect("Label_Tips")
  self.uiObjs.Label_Name = self.uiObjs.Img_Bg:FindDirect("Label_Name")
  self.uiObjs.Toggle_Captain = self.uiObjs.Label_Name:FindDirect("Toggle_Captain")
  self.uiObjs.Toggle_TeamMate = self.uiObjs.Label_Name:FindDirect("Toggle_TeamMate")
  self.uiObjs.Btn_Confirm = self.uiObjs.Img_Bg:FindDirect("Btn_Confirm")
  self.uiObjs.Btn_Cancel = self.uiObjs.Img_Bg:FindDirect("Btn_Cancel")
  self.uiObjs.Label_Empty = self.uiObjs.Img_Bg:FindDirect("Label_Empty")
end
def.method().UpdateInfo = function(self)
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo == nil then
    self:DestroyPanel()
    return
  end
  local teamData = require("Main.Team.TeamData").Instance()
  local mateData = teamData:getMember(mateInfo.mateId)
  if mateData == nil then
    self:DestroyPanel()
    return
  end
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  GUIUtils.SetText(self.uiObjs.Label_Tips, string.format(textRes.Children[1009], mateData.name, constant.CChildrenConsts.pregnant_cut_vigor_score))
  local Toggle_Captain = self.uiObjs.Label_Name:FindDirect("Toggle_Captain")
  local Toggle_TeamMate = self.uiObjs.Label_Name:FindDirect("Toggle_TeamMate")
  GUIUtils.SetText(Toggle_Captain:FindDirect("Label"), heroProp.name)
  GUIUtils.SetText(Toggle_TeamMate:FindDirect("Label"), mateData.name)
  local childrenDataMgr = ChildrenDataMgr.Instance()
  if childrenDataMgr:GetChildrenCountByRoleId(heroProp.id) == constant.CChildrenConsts.max_children_can_carrey and childrenDataMgr:GetChildrenCountByRoleId(mateInfo.mateId) == constant.CChildrenConsts.max_children_can_carrey then
    Toast(textRes.Children[1010])
    self:DestroyPanel()
    return
  elseif childrenDataMgr:GetChildrenCountByRoleId(heroProp.id) == constant.CChildrenConsts.max_children_can_carrey then
    self.uiObjs.Toggle_Captain:GetComponent("UIToggle").value = false
    self.uiObjs.Toggle_TeamMate:GetComponent("UIToggle").value = true
  else
    self.uiObjs.Toggle_TeamMate:GetComponent("UIToggle").value = false
    self.uiObjs.Toggle_Captain:GetComponent("UIToggle").value = true
  end
  GUIUtils.SetActive(self.uiObjs.Btn_Confirm, true)
  GUIUtils.SetActive(self.uiObjs.Btn_Cancel, true)
  GUIUtils.SetActive(self.uiObjs.Label_Empty, false)
end
def.method().ForceReadComment = function(self)
  if self.m_panel == nil then
    return
  end
  GUIUtils.SetActive(self.uiObjs.Btn_Confirm, false)
  GUIUtils.SetActive(self.uiObjs.Btn_Cancel, false)
  GUIUtils.SetActive(self.uiObjs.Label_Empty, true)
  self.remainTime = constant.CChildrenConsts.confirm_child_belong_seconds
  self:UpdateForceReadTips()
  self.forceReadTimerId = GameUtil.AddGlobalTimer(1, false, function()
    self.remainTime = self.remainTime - 1
    if self.remainTime < 0 then
      self:DestroyForceReadTimer()
      self:ShowChooseOperation()
      return
    end
    self:UpdateForceReadTips()
  end)
end
def.method().UpdateForceReadTips = function(self)
  GUIUtils.SetText(self.uiObjs.Label_Empty, string.format(textRes.Children[1052], constant.CChildrenConsts.confirm_child_belong_seconds, self.remainTime))
end
def.method().ShowChooseOperation = function(self)
  GUIUtils.SetActive(self.uiObjs.Btn_Confirm, true)
  GUIUtils.SetActive(self.uiObjs.Btn_Cancel, true)
  GUIUtils.SetActive(self.uiObjs.Label_Empty, false)
end
def.method().DestroyForceReadTimer = function(self)
  if self.forceReadTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.forceReadTimerId)
    self.forceReadTimerId = 0
  end
end
def.method().WaitForConfirm = function(self)
  if self.m_panel == nil then
    return
  end
  GUIUtils.SetActive(self.uiObjs.Btn_Confirm, false)
  GUIUtils.SetActive(self.uiObjs.Btn_Cancel, false)
  GUIUtils.SetActive(self.uiObjs.Label_Empty, true)
  self.remainTime = constant.CChildrenConsts.select_pregnant_wait_seconds
  self:UpdateWaitTips()
  self.waitTimerId = GameUtil.AddGlobalTimer(1, false, function()
    self.remainTime = self.remainTime - 1
    if self.remainTime < 0 then
      self:DestroyTipsTimer()
      return
    end
    self:UpdateWaitTips()
  end)
end
def.method().UpdateWaitTips = function(self)
  GUIUtils.SetText(self.uiObjs.Label_Empty, string.format(textRes.Children[1017], self.remainTime))
end
def.method().DestroyTipsTimer = function(self)
  if self.waitTimerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.waitTimerId)
    self.waitTimerId = 0
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" or id == "Btn_Cancel" then
    self:DestroyPanel()
  elseif id == "Btn_Confirm" then
    self:OnClickConfirmBtn()
  elseif id == "Toggle_Captain" then
    self:OnClickToggleCaptain()
  elseif id == "Toggle_TeamMate" then
    self:OnClickToggleTeamMate()
  end
end
def.method().OnClickConfirmBtn = function(self)
  local ownerRoleId = self:GetChildOwner()
  if ownerRoleId == nil then
    Toast(textRes.Children[1013])
    return
  end
  local curActive = require("Main.Hero.Interface").GetHeroProp().energy
  if curActive < constant.CChildrenConsts.pregnant_cut_vigor_score then
    Toast(string.format(textRes.Children[1015], textRes.Children[1016], constant.CChildrenConsts.pregnant_cut_vigor_score))
    return
  end
  local babyMgr = require("Main.Children.mgr.BabyMgr").Instance()
  babyMgr:SelectPregnantBelong(ownerRoleId)
end
def.method("=>", "userdata").GetChildOwner = function(self)
  if self.uiObjs.Toggle_Captain:GetComponent("UIToggle").value then
    local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
    local heroProp = HeroPropMgr.heroProp
    return heroProp and heroProp.id or nil
  elseif self.uiObjs.Toggle_TeamMate:GetComponent("UIToggle").value then
    local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
    return mateInfo and mateInfo.mateId or nil
  end
  return nil
end
def.method().OnClickToggleCaptain = function(self)
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr").Instance()
  local heroProp = HeroPropMgr.heroProp
  local childrenDataMgr = ChildrenDataMgr.Instance()
  if childrenDataMgr:GetChildrenCountByRoleId(heroProp.id) == constant.CChildrenConsts.max_children_can_carrey then
    self.uiObjs.Toggle_Captain:GetComponent("UIToggle").value = false
    self.uiObjs.Toggle_TeamMate:GetComponent("UIToggle").value = true
    Toast(textRes.Children[1011])
  end
end
def.method().OnClickToggleTeamMate = function(self)
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if mateInfo == nil then
    Toast(textRes.Children[1000])
    return
  end
  local childrenDataMgr = ChildrenDataMgr.Instance()
  if childrenDataMgr:GetChildrenCountByRoleId(mateInfo.mateId) == constant.CChildrenConsts.max_children_can_carrey then
    self.uiObjs.Toggle_Captain:GetComponent("UIToggle").value = true
    self.uiObjs.Toggle_TeamMate:GetComponent("UIToggle").value = false
    Toast(textRes.Children[1012])
  end
end
def.static("table", "table").OnChooseChildBelongResult = function(params, context)
  instance:DestroyPanel()
end
def.static("table", "table").OnTeamMemberChanged = function(param, tbl)
  instance:DestroyPanel()
  Toast(textRes.Children[1050])
end
def.static("table", "table").OnTeamMemberInfoChanged = function(param, tbl)
  instance:UpdateInfo()
end
ChooseChildOwnerPanel.Commit()
return ChooseChildOwnerPanel
