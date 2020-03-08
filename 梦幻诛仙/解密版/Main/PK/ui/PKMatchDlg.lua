local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local PKMatchDlg = Lplus.Extend(ECPanelBase, "PKMatchDlg")
local MENPAI = require("consts.mzm.gsp.occupation.confbean.SOccupationEnum")
local def = PKMatchDlg.define
local dlg
local GUIUtils = require("GUI.GUIUtils")
local PKData = require("Main.PK.data.PKData")
def.static("=>", PKMatchDlg).Instance = function()
  if dlg == nil then
    dlg = PKMatchDlg()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self.m_panel then
    self:DestroyPanel()
  end
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole == nil or not myRole:IsInState(RoleState.TXHW) then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PK_EFFECT_PANEL, 0)
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole == nil or not myRole:IsInState(RoleState.TXHW) then
    self:DestroyPanel()
  end
end
PKMatchDlg.Commit()
return PKMatchDlg
