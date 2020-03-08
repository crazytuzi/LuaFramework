local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgMatchInfo = Lplus.Extend(ECPanelBase, "DlgMatchInfo")
local def = DlgMatchInfo.define
local dlg
local teamData = require("Main.Team.TeamData").Instance()
local GUIUtils = require("GUI.GUIUtils")
def.static("=>", DlgMatchInfo).Instance = function()
  if dlg == nil then
    dlg = DlgMatchInfo()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_READY_INFO, DlgMatchInfo.OnUpdate)
  Event.RegisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, DlgMatchInfo.OnUpdate)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgMatchInfo.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgMatchInfo.OnLeaveFight)
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_MATCH_MINIMIZED, -1)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local bg = self.m_panel:FindDirect("Img_Bg")
  bg:SetActive(false)
  local btn = self.m_panel:FindDirect("Btn_FightCrossServer")
  GUIUtils.SetLightEffect(btn, GUIUtils.Light.Round)
  self:UpdateInfo()
end
def.method().Hide = function(self)
  if self.m_panel then
    local btn = self.m_panel:FindDirect("Btn_FightCrossServer")
    GUIUtils.SetLightEffect(btn, GUIUtils.Light.None)
  end
  self:DestroyPanel()
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.CROSS_SERVER, gmodule.notifyId.CrossServer.UPDATE_READY_INFO, DlgMatchInfo.OnUpdate)
  Event.UnregisterEvent(ModuleId.TEAM, gmodule.notifyId.Team.TEAM_MEMBER_NUM_CHANGED, DlgMatchInfo.OnUpdate)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgMatchInfo.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgMatchInfo.OnLeaveFight)
end
def.method().UpdateInfo = function(self)
  if self.m_panel == nil then
    return
  end
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.CROSS_SERVER)
  local teamMatchScore = mgr:GetTeamMatchScore()
  self.m_panel:FindDirect("Img_Bg/Group_Label/Label4"):GetComponent("UILabel").text = teamMatchScore
  local members = teamData:GetAllTeamMembers()
  self.m_panel:FindDirect("Img_Bg/Group_Label/Label5"):GetComponent("UILabel").text = tostring(#members) .. "/5"
  local ready_num = 1
  for i = 2, #members do
    if mgr:IsReady(members[i].roleid) then
      ready_num = ready_num + 1
    end
  end
  self.m_panel:FindDirect("Img_Bg/Group_Label/Label6"):GetComponent("UILabel").text = tostring(ready_num) .. "/5"
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Back" then
    self:Hide()
    require("Main.CrossServer.ui.DlgCrossServerTeam").Instance():ShowDlg()
  elseif id == "Btn_FightCrossServer" then
    local bg = self.m_panel:FindDirect("Img_Bg")
    bg:SetActive(not bg.activeSelf)
  elseif id == "Btn_Tips" then
    require("Main.CrossServer.ui.DlgPhaseInfo").Instance():ShowDlg()
    self:Hide()
  end
end
def.static("table", "table").OnUpdate = function(p1, p2)
  if dlg == nil then
    return
  end
  if teamData:HasTeam() then
    dlg:UpdateInfo()
  else
    dlg:Hide()
  end
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if dlg == nil or dlg.m_panel == nil then
    return
  end
  dlg.m_panel:SetActive(false)
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if dlg == nil or dlg.m_panel == nil then
    return
  end
  dlg.m_panel:SetActive(true)
end
return DlgMatchInfo.Commit()
