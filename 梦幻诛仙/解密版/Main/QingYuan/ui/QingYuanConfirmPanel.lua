local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QingYuanConfirmPanel = Lplus.Extend(ECPanelBase, "QingYuanConfirmPanel")
local QingYuanMgr = require("Main.QingYuan.QingYuanMgr")
local GUIUtils = require("GUI.GUIUtils")
local EC = require("Types.Vector3")
local def = QingYuanConfirmPanel.define
local instance
def.field("table").uiObjs = nil
def.field("userdata").activeRoleId = nil
def.field("userdata").passiveRoleId = nil
def.field("boolean").isSelfActiveRole = false
def.field("number").timerId = 0
def.static("=>", QingYuanConfirmPanel).Instance = function()
  if instance == nil then
    instance = QingYuanConfirmPanel()
  end
  return instance
end
def.method("userdata", "userdata").ShowPanel = function(self, activeRoleId, passiveRoleId)
  if self.m_panel ~= nil then
    return
  end
  local heroProp = require("Main.Hero.Interface").GetHeroProp()
  if heroProp == nil then
    return
  end
  self.isSelfActiveRole = activeRoleId == heroProp.id
  self.activeRoleId = activeRoleId
  self.passiveRoleId = passiveRoleId
  self:CreatePanel(RESPATH.PREFAB_QINGYUAN_CONFIRM_PANEL, 1)
  self:SetModal(true)
end
def.override().OnCreate = function(self)
  self:InitUI()
  self:RePositionButton()
  self:SetPlayerState()
  Event.RegisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.CANCEL_QINGYUAN, QingYuanConfirmPanel.OnOperateQingYuan)
  Event.RegisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.REFUSE_QINGYUAN, QingYuanConfirmPanel.OnOperateQingYuan)
  Event.RegisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.AGREE_QINGYUAN, QingYuanConfirmPanel.OnOperateQingYuan)
  Event.RegisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.ON_AGREE_QINGYUAN, QingYuanConfirmPanel.OnAgreeQingYuan)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_LEAVE, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_UPGRADE_TO_CAPTION, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, QingYuanConfirmPanel.OnFeatureOpenChange)
end
def.override().OnDestroy = function(self)
  self:StopWaitTimer()
  self.uiObjs = nil
  self.activeRoleId = nil
  self.passiveRoleId = nil
  self.isSelfActiveRole = false
  Event.UnregisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.CANCEL_QINGYUAN, QingYuanConfirmPanel.OnOperateQingYuan)
  Event.UnregisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.REFUSE_QINGYUAN, QingYuanConfirmPanel.OnOperateQingYuan)
  Event.UnregisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.AGREE_QINGYUAN, QingYuanConfirmPanel.OnOperateQingYuan)
  Event.UnregisterEvent(ModuleId.QINGYUAN, gmodule.notifyId.QingYuan.ON_AGREE_QINGYUAN, QingYuanConfirmPanel.OnAgreeQingYuan)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_CHANGE_LEADER, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_STATUS_CHANGED, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_LEAVE, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_UPGRADE_TO_CAPTION, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_JOIN_TEAM, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_ON_LEAVE_TEAM, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, QingYuanConfirmPanel.OnTeamMemberChanged)
  Event.UnregisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, QingYuanConfirmPanel.OnFeatureOpenChange)
end
def.method().InitUI = function(self)
  self.uiObjs = {}
  self.uiObjs.Img_0 = self.m_panel:FindDirect("Img_0")
  self.uiObjs.Group_Player_1 = self.uiObjs.Img_0:FindDirect("Group_Player_1")
  self.uiObjs.Group_Player_2 = self.uiObjs.Img_0:FindDirect("Group_Player_2")
  self.uiObjs.Btn_Confirm = self.uiObjs.Img_0:FindDirect("Btn_Confirm")
  self.uiObjs.Btn_Cancel = self.uiObjs.Img_0:FindDirect("Btn_Cancel")
  self.uiObjs.Btn_Close = self.uiObjs.Img_0:FindDirect("Btn_Close")
  self.uiObjs.Btn_Close:SetActive(false)
  self.uiObjs.Label = self.uiObjs.Img_0:FindDirect("Label")
  local tipContent = require("Main.Common.TipsHelper").GetHoverTip(constant.QingYuanConsts.makeQingYuanRelationTips)
  GUIUtils.SetText(self.uiObjs.Label, tipContent)
end
def.method().RePositionButton = function(self)
  local confirmPos = self.uiObjs.Btn_Confirm.localPosition
  local cancelPos = self.uiObjs.Btn_Cancel.localPosition
  if self.isSelfActiveRole then
    self.uiObjs.Btn_Confirm:SetActive(false)
    self.uiObjs.Btn_Cancel.localPosition = EC.Vector3.new((confirmPos.x + cancelPos.x) / 2, confirmPos.y, 0)
  end
end
def.method().SetPlayerState = function(self)
  local teamData = require("Main.Team.TeamData").Instance()
  local members = teamData:GetAllTeamMembers()
  if members == nil or #members ~= 2 then
    Toast(textRes.QingYuan[15])
    self:DestroyPanel()
    return
  end
  local group = {
    self.uiObjs.Group_Player_1,
    self.uiObjs.Group_Player_2
  }
  for i = 1, 2 do
    local player = group[i]
    local playerName = player:FindDirect("Label_PlayerName_1")
    local Label_Confirm = player:FindDirect("Label_Confirm")
    local Label_Waiting = player:FindDirect("Label_Waiting")
    local PlayerHead = player:FindDirect("Img_Player_1/Img_IconItem")
    GUIUtils.SetText(playerName, members[i].name)
    GUIUtils.SetSprite(PlayerHead, GUIUtils.GetHeadSpriteName(members[i].menpai, members[i].gender))
    GUIUtils.SetActive(Label_Waiting, i ~= 1)
    GUIUtils.SetActive(Label_Confirm, i == 1)
  end
  self:UpdatePlayerState(constant.QingYuanConsts.waitSeconds)
  self:StartWaitTimer()
end
def.method().StartWaitTimer = function(self)
  local leftTime = constant.QingYuanConsts.waitSeconds
  self.timerId = GameUtil.AddGlobalTimer(1, false, function()
    leftTime = leftTime - 1
    self:UpdatePlayerState(leftTime)
    if leftTime <= 0 then
      self:StopWaitTimer()
      self:DestroyPanel()
    end
  end)
end
def.method("number").UpdatePlayerState = function(self, leftTime)
  if self.uiObjs == nil then
    return
  end
  GUIUtils.SetText(self.uiObjs.Group_Player_2:FindDirect("Label_Waiting"), string.format(textRes.QingYuan[16], leftTime))
  if not self.isSelfActiveRole then
    GUIUtils.SetText(self.uiObjs.Btn_Cancel:FindDirect("Label_Cancel"), string.format(textRes.QingYuan[14], leftTime))
  else
    GUIUtils.SetText(self.uiObjs.Btn_Cancel:FindDirect("Label_Cancel"), textRes.QingYuan[13])
  end
end
def.method().StopWaitTimer = function(self)
  if self.timerId ~= 0 then
    GameUtil.RemoveGlobalTimer(self.timerId)
    self.timerId = 0
  end
end
def.method().AgreeQingYuan = function(self)
  GUIUtils.SetActive(self.uiObjs.Group_Player_2:FindDirect("Label_Waiting"), false)
  GUIUtils.SetActive(self.uiObjs.Group_Player_2:FindDirect("Label_Confirm"), true)
  GUIUtils.SetText(self.uiObjs.Btn_Cancel:FindDirect("Label_Cancel"), textRes.QingYuan[13])
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    QingYuanMgr.Instance():AgreeQingYuanReq()
  elseif id == "Btn_Cancel" then
    if self.isSelfActiveRole then
      QingYuanMgr.Instance():CancelQingYuanReq()
    else
      QingYuanMgr.Instance():RefuseQingYuanReq()
      self:DestroyPanel()
    end
  end
end
def.method().Close = function(self)
  self:DestroyPanel()
end
def.static("table", "table").OnOperateQingYuan = function(params, context)
  local self = instance
  if self ~= nil then
    self:Close()
  end
end
def.static("table", "table").OnAgreeQingYuan = function(params, context)
  local self = instance
  if self ~= nil then
    self:StopWaitTimer()
    self:AgreeQingYuan()
  end
end
def.static("table", "table").OnTeamMemberChanged = function(param, tbl)
  local self = instance
  if self ~= nil then
    Toast(textRes.QingYuan[22])
    self:Close()
  end
end
def.static("table", "table").OnFeatureOpenChange = function(params, context)
  local self = instance
  if self ~= nil and not QingYuanMgr.Instance():IsQingYuanFunctionOpen() then
    Toast(textRes.QingYuan[26])
    self:Close()
  end
end
QingYuanConfirmPanel.Commit()
return QingYuanConfirmPanel
