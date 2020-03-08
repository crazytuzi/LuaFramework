local Lplus = require("Lplus")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local Network = require("netio.Network")
local ECMSDK = require("ProxySDK.ECMSDK")
local FMShow = require("Main.Chat.ui.FMShow")
local ErrorCodes = require("netio.protocol.mzm.gsp.apollo.ErrorCodes")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local CommonGuideTip = require("GUI.CommonGuideTip")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECQQEC = Lplus.Class("ECQQEC")
local def = ECQQEC.define
def.const("table").STATE = {
  UNINIT = 1,
  PREPARED = 2,
  LIVESTARTING = 3,
  LIVESTAR = 4,
  LIVEPAUSE = 5,
  LIVESTOPPING = 6,
  LIVESTOPPED = 7,
  ERROR = 8,
  INTERNAL = 9
}
def.field("boolean").m_IsOpen = true
def.field("boolean").m_IsInit = false
def.field("number").m_State = 1
local instance
def.static("=>", ECQQEC).Instance = function()
  if not instance then
    instance = ECQQEC()
  end
  return instance
end
local isSupported
def.static("=>", "boolean").IsSurportQQEC = function()
  if platform == 1 then
    return true
  end
  if isSupported == nil then
    if QQEC and QQEC.IsSupported then
      isSupported = QQEC.IsSupported()
      warn("Does your deivce surport QQEC ?????????????????????????", isSupported)
      return isSupported
    end
    return false
  else
    return isSupported
  end
end
def.static("=>", "boolean").IsOpen = function()
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local open = require("Main.FeatureOpenList.FeatureOpenListModule").Instance():CheckFeatureOpen(Feature.TYPE_APOLLO)
  return open
end
def.static("=>", "boolean").InitQQEC = function()
  local sdktype = ClientCfg.GetSDKType()
  if sdktype ~= ClientCfg.SDKTYPE.MSDK then
    return false
  end
  if not instance or not instance.m_IsOpen then
    Debug.LogWarning("The feature of QQEC is forbidden ~~~~~~~~~~~~ InitQQEC")
    return false
  end
  if instance.m_IsInit then
    Debug.LogWarning("QQEC Componet is already Inited")
    return true
  end
  if QQEC and QQEC.Init then
    warn(ECMSDK.APPID.QQ, " InitQQEC ==================999999")
    instance.m_IsInit = QQEC.Init(ECMSDK.APPID.QQ, 0)
    return instance.m_IsInit
  end
  return false
end
def.static().TearDown = function()
  if QQEC and QQEC.TearDown then
    QQEC.TearDown()
  end
end
def.static().EnterLiveHall = function()
  if not instance or not instance.m_IsOpen then
    Toast(textRes.Common[55])
    return
  end
  if not instance.m_IsInit then
    Debug.LogWarning("ECQQEC doesn't Init")
    return
  end
  if QQEC and QQEC.EnterLiveHall then
    QQEC.EnterLiveHall()
  end
end
def.static().EnterLiveHallInGame = function()
  if not instance or not instance.m_IsOpen then
    Toast(textRes.Common[55])
    return
  end
  if not instance.m_IsInit then
    Debug.LogWarning("ECQQEC doesn't Init")
    return
  end
  if QQEC and QQEC.EnterLiveHallInGame then
    QQEC.EnterLiveHallInGame()
  end
end
def.static().Reset = function()
  if QQEC and QQEC.Reset then
    QQEC.Reset()
  end
end
def.static().Pause = function()
  if QQEC and QQEC.Pause then
    QQEC.Pause()
  end
end
def.static().Resume = function()
  if QQEC and QQEC.Resume then
    QQEC.Resume()
  end
end
def.static().SetUserAccount = function()
  if QQEC and QQEC.SetUserAccount then
    local sdkInfo = ECMSDK.GetMSDKInfo()
    local phoneNum = ""
    local expires = 0
    local platform = 0
    if _G.LoginPlatform == MSDK_LOGIN_PLATFORM.QQ then
      platform = 1
    elseif _G.LoginPlatform == MSDK_LOGIN_PLATFORM.WX then
      platform = 2
    end
    warn("ECQQEC SetUserAccount", _G.LoginPlatform, " ", sdkInfo.appId, " ", sdkInfo.openId, " ", sdkInfo.accessToken, " ", phoneNum, expires)
    QQEC.SetUserAccount(platform, sdkInfo.appId, sdkInfo.openId, sdkInfo.accessToken, phoneNum, expires)
  end
end
def.static().UpdateUserAccount = function()
  if not instance or not instance.m_IsInit then
    return
  end
  if QQEC and QQEC.UpdateUserAccount then
    QQEC.UpdateUserAccount()
  end
end
def.static("number", "string", "string", "userdata", "number").SetCommentNotify = function(type, nick, content, time, timeValue)
  warn("ECQQEC SetCommentNotify:", type, " ", nick, " ", content, " ", time, " ", timeValue)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.QQECCommentNotify, {
    type = type,
    nick = nick,
    content = content,
    time = time,
    timeValue = timeValue
  })
end
def.static("number").SetStatusNotify = function(newState)
  warn("ECQQEC SetStatusNotify:", newState)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.QQECStatusChange, {status = newState})
end
def.static("string", "string", "string", "string", "string").SetShareNotify = function(openid, title, desc, targetUrl, imageUrl)
  warn("ECQQEC SetShareNotify:", openid, " ", title, " ", desc, " ", targetUrl, " ", imageUrl)
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.QQECShareNotify, {
    openid = openid,
    title = title,
    desc = desc,
    targetUrl = targetUrl,
    imageUrl = imageUrl
  })
end
def.static("number").WebViewNotify = function(newState)
  warn("ECQQEC WebViewNotify:", newState)
  if newState == 1 then
    local ECGUIMan = require("GUI.ECGUIMan")
    ECGUIMan.Instance():LockUIForever(false)
  end
end
def.static("number").GetErrorCode = function()
  if QQEC and QQEC.GetErrorCode then
    return QQEC.GetErrorCode()
  end
end
def.static().StartLive = function()
  if QQEC and QQEC.Start then
    QQEC.Start()
  end
end
def.static().StopLive = function()
  if QQEC and QQEC.Stop then
    QQEC.Stop()
  end
end
def.static().OnResume = function()
  if not instance or not instance.m_IsInit then
    return
  end
  if QQEC and QQEC.OnResume then
    QQEC.OnResume()
  end
end
def.static().OnPause = function()
  if not instance or not instance.m_IsInit then
    return
  end
  if QQEC and QQEC.OnPause then
    QQEC.OnPause()
  end
end
def.static().OnDestroy = function()
  if QQEC and QQEC.OnDestroy then
    QQEC.OnDestroy()
  end
end
def.static("=>", "boolean").OnBackPressed = function()
  if not instance or not instance.m_IsInit then
    return false
  end
  if QQEC and QQEC.OnBackPressed then
    return QQEC.OnBackPressed()
  end
  return false
end
def.static("table", "table").OnLoginAccountSuccess = function(p)
end
def.static("table", "table").OnSettingChanged = function(p)
  warn("OnSettingChanged", p[1])
end
def.static("table", "table").OnInitQQEC = function(p)
  warn("OnInitQQEC--------------------", p.switch)
  if instance then
    instance.m_IsOpen = p.switch
    if p.switch and platform == 2 then
      local ECQQEC = require("ProxySDK.ECQQEC")
      if ECQQEC.InitQQEC() then
        warn("Success to init QQE")
      end
    end
  end
end
def.static("table", "table").OnFeatureOpenChange = function(p)
  warn(instance.m_IsInit, "ECQQEC OnFeatureOpenChange--------------------", p.feature, p.open)
  if p.feature == 125 and instance then
    instance.m_IsOpen = p.open
    if p.open and not instance.m_IsInit then
      ECQQEC.InitQQEC()
    end
  end
end
def.method().ClearData = function(self)
  if self.m_IsInit then
    ECQQEC.StopLive()
  end
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    self:ClearData()
  end)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ECQQEC.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.CHAT, gmodule.notifyId.Chat.InitQQEC, ECQQEC.OnInitQQEC)
end
ECQQEC.Commit()
return ECQQEC
