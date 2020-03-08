local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgLeaderBattleBtn = Lplus.Extend(ECPanelBase, "DlgLeaderBattleBtn")
local def = DlgLeaderBattleBtn.define
local dlg
def.static("=>", DlgLeaderBattleBtn).Instance = function()
  if dlg == nil then
    dlg = DlgLeaderBattleBtn()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    return
  end
  self:CreatePanel(RESPATH.DLG_LEADER_BATTTL_BTN, 0)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgLeaderBattleBtn.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgLeaderBattleBtn.OnLeaveFight)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, DlgLeaderBattleBtn.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, DlgLeaderBattleBtn.OnLeaveFight)
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
  if id == "Btn_ZhengBa" then
    require("Main.PVP.ui.DlgLeaderBattleRank").Instance():ShowDlg()
  end
end
DlgLeaderBattleBtn.Commit()
return DlgLeaderBattleBtn
