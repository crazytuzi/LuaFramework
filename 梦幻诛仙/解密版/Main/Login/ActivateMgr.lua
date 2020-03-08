local Lplus = require("Lplus")
local ActivateMgr = Lplus.Class("ActivateMgr")
local LoginUIMgr = require("Main.Login.LoginUIMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local def = ActivateMgr.define
local ACTIVATE_KEY_PATTERN = "^[a-hj-np-zA-HJ-NP-Z]*$"
local ACTIVATE_KEY_LEN = 13
local instance
def.static("=>", ActivateMgr).Instance = function()
  if instance == nil then
    instance = ActivateMgr()
  end
  return instance
end
def.method().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.csprovider.SRequireUseActivateCard", ActivateMgr._OnSRequireUseActivateCard)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.csprovider.SUseActivateCardSuccess", ActivateMgr._OnSUseActivateCardSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.csprovider.SUseActivateCardFailed", ActivateMgr._OnSUseActivateCardFailed)
end
def.method("string", "=>", "boolean").Activate = function(self, key)
  local matchstr = string.match(key, ACTIVATE_KEY_PATTERN)
  if matchstr == nil or #matchstr ~= ACTIVATE_KEY_LEN then
    return false
  end
  self:C2S_UseActivateCardReq(key)
  return true
end
def.static("table")._OnSRequireUseActivateCard = function(p)
  gmodule.network.resumeProtocolUpdate()
  require("GUI.WaitingTip").HideTip()
  LoginUIMgr.Instance():ShowActivateUI()
end
def.static("table")._OnSUseActivateCardSuccess = function(p)
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ACTIVATE_SUCCESS, nil)
  Toast(textRes.Login[28])
  require("GUI.WaitingTip").ShowTip(textRes.Login[23])
  local loginModule = LoginModule.Instance()
  loginModule.loginTarget = LoginModule.LoginTarget.Server
  loginModule:C2S_GetRoleList()
end
def.static("table")._OnSUseActivateCardFailed = function(p)
  local reason = p.reason
  Toast(textRes.CSProvider.SUseActivateCardFailed[reason] or "Unknow reason : " .. reason)
end
def.method("string").C2S_UseActivateCardReq = function(self, key)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.csprovider.CUseActivateCardReq").new(key))
end
return ActivateMgr.Commit()
