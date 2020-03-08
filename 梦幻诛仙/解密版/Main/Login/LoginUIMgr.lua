local MODULE_NAME = (...)
local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local LoginUIMgr = Lplus.Class("LoginUIMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local def = LoginUIMgr.define
local UISet = {
  Active = "ActivatePanel",
  ChooseServer = "ChooseServerPanel",
  CreateRole = "CreateRolePanel",
  SelectRole = "SelectRolePanel",
  LoginMain = "LoginMainPanel",
  LoginUpdate = "LoginUpdatePanel",
  DlgLogin = "DlgLogin",
  LoginQueue = "LoginQueuePanel"
}
def.const("table").UISet = UISet
def.field("string").modulePrefix = ""
local instance
def.static("=>", LoginUIMgr).Instance = function()
  if instance == nil then
    instance = LoginUIMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, LoginUIMgr.OnResetUI)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_QUEUE_INFO_UPDATE, LoginUIMgr.OnLoginQueueInfoUpdate)
end
def.method("string", "=>", "table").GetUI = function(self, uiName)
  return require(self:_GetModulePrefix() .. ".ui." .. uiName)
end
def.static("table", "table").OnResetUI = function()
  require("GUI.WaitingTip").HideTip()
end
def.method().ShowActivateUI = function(self)
  self:GetUI(UISet.Active).Instance():ShowPanel()
end
def.method().ShowCreateRoleUI = function(self)
  self:GetUI(UISet.CreateRole).Instance():ShowPanel()
end
def.method().ShowSelectRoleUI = function(self)
  self:GetUI(UISet.SelectRole).Instance():ShowPanel()
end
def.method().ShowChooseServerUI = function(self)
  self:GetUI(UISet.ChooseServer).Instance():ShowPanel()
end
def.method().ShowLoginMainUI = function(self)
  self:GetUI(UISet.LoginMain).Instance():ShowPanel()
end
def.method().ShowInputAccountUI = function(self)
  self:GetUI(UISet.DlgLogin).Instance():ShowDlg()
end
def.method("userdata", "userdata", "string").ShowRoleBeBannedPrompt = function(self, roleId, endTime, reason)
  reason = self:ConvertReason(reason)
  local timeText = self:Conervt2TimeText(endTime)
  local roleInfo = LoginModule.Instance():GetRoleInfo(roleId)
  local rolename = roleInfo and roleInfo.basic.name or ""
  local tipContent = string.format(textRes.Login[63], rolename, reason, timeText)
  require("GUI.CommonConfirmDlg").ShowCerternConfirm(textRes.Common[8], tipContent, "", function(...)
    if LoginModule.Instance():IsInWorld() then
      LoginModule.Instance():Back2Login()
    end
  end, {m_level = 0})
end
def.method("userdata", "string").ShowUserBeBannedPrompt = function(self, endTime, reason)
  reason = self:ConvertReason(reason)
  local timeText = self:Conervt2TimeText(endTime)
  local tipContent = string.format(textRes.Login[59], reason, timeText)
  require("GUI.CommonConfirmDlg").ShowCerternConfirm(textRes.Common[8], tipContent, "", function(...)
    LoginModule.Instance():Back2Login()
  end, {m_level = 0})
end
def.method("string", "=>", "string").ConvertReason = function(self, reason)
  if reason == "idip" then
    return textRes.Login[64]
  end
  return reason
end
def.method("userdata", "=>", "string").Conervt2TimeText = function(self, endTime)
  local endTime = Int64.ToNumber(endTime)
  local timeText = os.date("%Y/%m/%d %H:%M:%S", endTime)
  if timeText == nil then
    local INT32_MAX = 2147483647
    timeText = os.date("%Y/%m/%d %H:%M:%S", INT32_MAX) or "date error"
  end
  return timeText
end
def.method().ShowAccountNumLimitTip = function(self)
  local tipContent = textRes.Login[54]
  require("GUI.CommonConfirmDlg").ShowCerternConfirm(textRes.Common[8], tipContent, "", nil, nil)
end
def.method("=>", "string")._GetModulePrefix = function(self)
  if self.modulePrefix == "" then
    self:_InitModulePrefix()
  end
  return self.modulePrefix
end
def.method()._InitModulePrefix = function(self)
  local sPos, ePos = string.find(MODULE_NAME, ".[%w_]+$")
  self.modulePrefix = string.sub(MODULE_NAME, 1, sPos - 1)
end
def.static("table", "table").OnLoginQueueInfoUpdate = function(params, context)
  instance:GetUI(UISet.LoginQueue).Instance():ShowPanel()
end
return LoginUIMgr.Commit()
