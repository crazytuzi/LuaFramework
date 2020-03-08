local CUR_CLASS_NAME = (...)
local Lplus = require("Lplus")
local Operation = import(".Operation")
local EnterApolloRoom = Lplus.Extend(Operation, CUR_CLASS_NAME)
local ECApollo = Lplus.ForwardDeclare("ECApollo")
local def = EnterApolloRoom.define
def.override("table", "=>", "boolean").Operate = function(self, params)
  local FMShow = require("Main.Chat.ui.FMShow")
  local panel = FMShow.Instance()
  if panel.m_panel == nil or panel.m_panel.isnil then
    return
  end
  local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.ANCHOR)
  local toggleState = require("Main.MainUI.ui.MainUIChat").Instance():GetToggleState()
  if setting.isEnabled and ECApollo.IsOpen() then
    panel:onClick("Btn_SwtichOn")
    return true
  end
  return false
end
return EnterApolloRoom.Commit()
