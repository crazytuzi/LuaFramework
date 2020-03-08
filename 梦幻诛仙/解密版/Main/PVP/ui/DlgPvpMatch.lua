local Lplus = require("Lplus")
local ECPanelBase = require("GUI.ECPanelBase")
local DlgPvpMatch = Lplus.Extend(ECPanelBase, "DlgPvpMatch")
local def = DlgPvpMatch.define
local dlg
def.static("=>", DlgPvpMatch).Instance = function()
  if dlg == nil then
    dlg = DlgPvpMatch()
  end
  return dlg
end
def.method().ShowDlg = function(self)
  if self:IsShow() then
    return
  end
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole == nil then
    return
  end
  self:CreatePanel(RESPATH.PREFAB_PK_EFFECT_PANEL, 0)
end
def.method().Hide = function(self)
  self:DestroyPanel()
end
def.override("boolean").OnShow = function(self, s)
  if s == false then
    return
  end
  local myRole = gmodule.moduleMgr:GetModule(ModuleId.HERO).myRole
  if myRole == nil then
    self:DestroyPanel()
  end
end
DlgPvpMatch.Commit()
return DlgPvpMatch
