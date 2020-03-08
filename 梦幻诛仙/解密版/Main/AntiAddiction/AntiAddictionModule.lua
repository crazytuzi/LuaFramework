local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local AntiAddictionModule = Lplus.Extend(ModuleBase, "AntiAddictionModule")
require("Main.module.ModuleId")
local def = AntiAddictionModule.define
local instance
def.static("=>", AntiAddictionModule).Instance = function()
  if not instance then
    instance = AntiAddictionModule()
    instance.m_moduleId = ModuleId.ANTIADDICTION
  end
  return instance
end
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.addiction.SPopup", AntiAddictionModule.ShowDlg)
  require("Main.AntiAddiction.AntiAddictionMgr").Instance():Init()
end
def.static("table").ShowDlg = function(msg)
  warn("open addiction panel")
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  if not feature:CheckFeatureOpen(Feature.TYPE_ADDICTION) then
    return
  end
  if not msg or not msg.popup_type then
    return
  end
  local _content = textRes.AntiAddiction[msg.popup_type] or ""
  local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
  CommonConfirmDlg.ShowCerternConfirm(textRes.AntiAddiction[3], _content, textRes.AntiAddiction[4], nil, nil)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.addiction.CPopup").new(msg.popup_type))
end
AntiAddictionModule.Commit()
return AntiAddictionModule
