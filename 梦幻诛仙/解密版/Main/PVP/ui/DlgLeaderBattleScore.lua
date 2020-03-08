local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgLeaderBattleScore = Lplus.Extend(ECPanelBase, "DlgLeaderBattleScore")
local def = DlgLeaderBattleScore.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
def.static("=>", DlgLeaderBattleScore).Instance = function()
  if dlg == nil then
    dlg = DlgLeaderBattleScore()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  self:CreatePanel(RESPATH.DLG_LEADER_BATTTL_SCORE, 0)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:UpdateScore()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgLeaderBattleScore.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgLeaderBattleScore.OnLeaveFight)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, DlgLeaderBattleScore.OnHeroStatusChange)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgLeaderBattleScore.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgLeaderBattleScore.OnLeaveFight)
  Event.UnregisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_STATUS_CHANGED, DlgLeaderBattleScore.OnHeroStatusChange)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.static("table", "table").OnEnterFight = function(p1, p2)
  if dlg.m_panel then
    dlg.m_panel:SetActive(false)
  end
end
def.static("table", "table").OnLeaveFight = function(p1, p2)
  if dlg.m_panel then
    dlg.m_panel:SetActive(true)
  end
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Close" then
    if gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:IsInState(RoleState.SXZB) then
      if self.m_panel.activeSelf then
        self.m_panel:FindDirect("Group_Open"):SetActive(false)
        self.m_panel:FindDirect("Group_Close"):SetActive(true)
      end
    else
      self:Hide()
    end
  elseif id == "Btn_Open" and self.m_panel.activeSelf then
    self.m_panel:FindDirect("Group_Open"):SetActive(true)
    self.m_panel:FindDirect("Group_Close"):SetActive(false)
  end
end
def.method().UpdateScore = function(self)
  if self.m_panel == nil then
    return
  end
  local scoreInfo = gmodule.moduleMgr:GetModule(ModuleId.LEADER_BATTLE).scoreInfo
  if scoreInfo then
    self.m_panel:FindDirect("Group_Open/GroupScore/Label_Num"):GetComponent("UILabel").text = scoreInfo.score
    self.m_panel:FindDirect("Group_Open/Group_Win/Label_Num"):GetComponent("UILabel").text = scoreInfo.win_times
    self.m_panel:FindDirect("Group_Open/Group_Fail/Label_Num"):GetComponent("UILabel").text = scoreInfo.lose_times
  end
end
def.static("table", "table").OnHeroStatusChange = function()
  if not gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole:IsInState(RoleState.SXZB) then
    dlg:Hide()
  end
end
DlgLeaderBattleScore.Commit()
return DlgLeaderBattleScore
