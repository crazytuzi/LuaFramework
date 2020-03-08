local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local QimaiBtn = Lplus.Extend(ECPanelBase, "QimaiBtn")
local def = QimaiBtn.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
def.static("=>", QimaiBtn).Instance = function()
  if dlg == nil then
    dlg = QimaiBtn()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    return
  end
  self:CreatePanel(RESPATH.DLG_QIMAI_BTN, 0)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  if require("Main.Fight.FightMgr").Instance().isInFight then
    self.m_panel:SetActive(false)
  end
  self:ShowRedTip()
end
def.override().OnCreate = function(self)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, QimaiBtn.OnEnterFight)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, QimaiBtn.OnLeaveFight)
  Event.RegisterEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_INFO, QimaiBtn.UpdateInfo)
end
def.override().OnDestroy = function(self)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.ENTER_FIGHT, QimaiBtn.OnEnterFight)
  Event.UnregisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, QimaiBtn.OnLeaveFight)
  Event.UnregisterEvent(ModuleId.QIMAI_HUIWU, gmodule.notifyId.Qimai.UPDATE_INFO, QimaiBtn.UpdateInfo)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method().ShowRedTip = function(self)
  if self.m_panel == nil then
    return
  end
  local mgr = gmodule.moduleMgr:GetModule(ModuleId.QIMAI_HUIWU)
  local one = mgr.oneVictoryClaimed == false and mgr.win > 0
  local five = mgr.fiveBattleClaimed == false and mgr.win + mgr.lose >= 5
  self.m_panel:FindDirect("Btn_QiMai/Img_PVP3Red"):SetActive(one or five)
  local light = GUIUtils.Light.None
  if one or fine then
    light = GUIUtils.Light.Round
  end
  GUIUtils.SetLightEffect(self.m_panel:FindDirect("Btn_QiMai"), light)
end
def.static("table", "table").UpdateInfo = function(p1, p2)
  dlg:ShowRedTip()
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
  if id == "Btn_QiMai" then
    require("Main.Qimai.ui.QimaiMainDlg").Instance():ShowDlg()
  end
end
QimaiBtn.Commit()
return QimaiBtn
