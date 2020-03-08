local MODULE_NAME = (...)
local Lplus = require("Lplus")
local WechatInviteAwardMgr = Lplus.Class(MODULE_NAME)
local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
local def = WechatInviteAwardMgr.define
local NOT_SET = -1
local HAS_KNOWN_KEY = "WechatInviteAwardMgr_HasKnown"
local FEATURE_TYPE = Feature.TYPE_WECHAT_INVITE_H5_ACTIVITY
local debuglog = function(formatstr, ...)
  if type(formatstr) == "string" then
    print(formatstr:format(...))
  else
    print(...)
  end
end
local instance
def.static("=>", WechatInviteAwardMgr).Instance = function()
  if not instance then
    instance = WechatInviteAwardMgr()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenInit, WechatInviteAwardMgr.OnFunctionOpenInit)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, WechatInviteAwardMgr.OnFunctionOpenChange)
end
def.method("=>", "boolean").IsOpen = function(self)
  if not self:IsFeatureOpen() then
    debuglog("feature(%d) not open", FEATURE_TYPE)
    return false
  end
  if ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK and LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
    return true
  end
  if platform == 0 then
    return true
  end
  return false
end
def.method("=>", "boolean").IsFeatureOpen = function(self)
  if FEATURE_TYPE == NOT_SET then
    return true
  end
  local feature = require("Main.FeatureOpenList.FeatureOpenListModule").Instance()
  local isOpen = feature:CheckFeatureOpen(FEATURE_TYPE)
  return isOpen
end
def.method("=>", "number").GetNotifyMessageCount = function(self)
  if not self:IsOpen() then
    return 0
  end
  if self:HasKnown() then
    return 0
  else
    return 1
  end
end
def.method("=>", "boolean").HasKnown = function(self)
  return LuaPlayerPrefs.HasRoleKey(HAS_KNOWN_KEY)
end
def.method("boolean").SetKnow = function(self, isKnow)
  if isKnow then
    LuaPlayerPrefs.SetRoleInt(HAS_KNOWN_KEY, 1)
  else
    LuaPlayerPrefs.DeleteRoleKey(HAS_KNOWN_KEY)
  end
  LuaPlayerPrefs.Save()
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):UpdateNotifyMessages()
end
def.method().OnFeatureStatusChange = function(self)
  local isOpen = self:IsFeatureOpen()
  local activityId = constant.CConstellationConsts.Activityid
  if isOpen then
  else
    Event.DispatchEvent(ModuleId.AWARD, gmodule.notifyId.Award.WECHAT_INVITE_AWARD_CLOSE, nil)
  end
  gmodule.moduleMgr:GetModule(ModuleId.AWARD):UpdateNotifyMessages()
end
def.static("table", "table").OnFunctionOpenInit = function(params)
  instance:OnFeatureStatusChange()
end
def.static("table", "table").OnFunctionOpenChange = function(params)
  if params and params.feature == FEATURE_TYPE then
    instance:OnFeatureStatusChange()
  end
end
return WechatInviteAwardMgr.Commit()
