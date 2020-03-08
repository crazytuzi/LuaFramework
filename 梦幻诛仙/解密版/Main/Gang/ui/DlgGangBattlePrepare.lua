local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgGangBattlePrepare = Lplus.Extend(ECPanelBase, "DlgGangBattlePrepare")
local GangBattleMgr = require("Main.Gang.GangBattleMgr")
local def = DlgGangBattlePrepare.define
local dlg
def.field("number").leftTime = 0
def.static("=>", DlgGangBattlePrepare).Instance = function()
  if dlg == nil then
    dlg = DlgGangBattlePrepare()
  end
  return dlg
end
def.override().OnCreate = function(self)
  Timer:RegisterListener(self.UpdateCountDown, self)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.LEAVE_GANG_BATTLE_MAP, DlgGangBattlePrepare.OnStatusChanged)
  Event.RegisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Battle_Prepare_Player_Changed, DlgGangBattlePrepare.OnPlayerNumChanged)
end
def.method("number").ShowDlg = function(self, leftTime)
  self.leftTime = leftTime
  if not self:IsShow() then
    self:CreatePanel(RESPATH.PREFAB_GANG_BATTLE_PREPARE, 0)
  end
end
def.override().OnDestroy = function(self)
  Timer:RemoveListener(self.UpdateCountDown)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.LEAVE_GANG_BATTLE_MAP, DlgGangBattlePrepare.OnStatusChanged)
  Event.UnregisterEvent(ModuleId.GANG, gmodule.notifyId.Gang.Gang_Battle_Prepare_Player_Changed, DlgGangBattlePrepare.OnPlayerNumChanged)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  self:ShowInfo()
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.method("string").onClick = function(self, id)
  if id == "Btn_Confirm" then
    self:Hide()
  elseif id == "Btn_Cancel" then
    self:Hide()
  end
end
def.method().ShowInfo = function(self)
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  self.m_panel:FindDirect("Img_Bg/Img_MovePower/Label_Num"):GetComponent("UILabel").text = tostring(GangBattleMgr.Instance().actionPoint)
  self.m_panel:FindDirect("Img_Bg/Img_PersonNum/Label_Num"):GetComponent("UILabel").text = tostring(GangBattleMgr.Instance().preparePlayerNum)
  local left = Seconds2HMSTime(self.leftTime)
  self.m_panel:FindDirect("Img_Bg/Img_LeftTime/Label_Num"):GetComponent("UILabel").text = string.format(textRes.Gang[214], left.m, left.s)
end
def.static("table", "table").OnPlayerNumChanged = function(p1, p2)
  if dlg.m_panel == nil or dlg.m_panel.isnil then
    return
  end
  dlg.m_panel:FindDirect("Img_Bg/Img_PersonNum/Label_Num"):GetComponent("UILabel").text = tostring(GangBattleMgr.Instance().preparePlayerNum)
end
def.method("number").UpdateCountDown = function(self, tk)
  if self.leftTime <= 0 then
    return
  end
  self.leftTime = self.leftTime - tk
  if self.m_panel == nil or self.m_panel.isnil then
    return
  end
  local left = Seconds2HMSTime(self.leftTime)
  self.m_panel:FindDirect("Img_Bg/Img_LeftTime/Label_Num"):GetComponent("UILabel").text = string.format(textRes.Gang[214], left.m, left.s)
end
def.static("table", "table").OnStatusChanged = function(p1, p2)
  dlg:Hide()
end
DlgGangBattlePrepare.Commit()
return DlgGangBattlePrepare
