local Lplus = require("Lplus")
local CommonConfirmDlg = require("GUI.CommonConfirmDlg")
local Network = require("netio.Network")
local ECMSDK = require("ProxySDK.ECMSDK")
local ErrorCodes = require("netio.protocol.mzm.gsp.apollo.ErrorCodes")
local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
local CommonGuideTip = require("GUI.CommonGuideTip")
local ECGame = Lplus.ForwardDeclare("ECGame")
local ECReplayKit = Lplus.Class("ECReplayKit")
local def = ECReplayKit.define
def.const("table").STATUS = {
  NON = 0,
  START = 1,
  STOP = 2
}
def.field("boolean").m_MicState = false
def.field("number").m_Status = 0
def.field("number").m_TimerID = 0
local instance
def.static("=>", ECReplayKit).Instance = function()
  if not instance then
    instance = ECReplayKit()
  end
  return instance
end
def.static("boolean").OnStart = function(success)
  warn("ECReplayKit OnStart1111111111111111 ", success)
  if success then
    instance.m_Status = ECReplayKit.STATUS.START
    local IOSLivePanel = require("Main.Chat.ui.IOSLivePanel")
    IOSLivePanel.Instance():ShowPanel()
  end
  ECReplayKit.ClearTimer()
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.ReplayKit, {
    status = instance.m_Status
  })
end
def.static().OnStop = function()
  warn("ECReplayKit OnStop")
  ECReplayKit.ClearTimer()
  local IOSLivePanel = require("Main.Chat.ui.IOSLivePanel")
  IOSLivePanel.Instance():DestroyPanel()
  instance.m_Status = ECReplayKit.STATUS.STOP
  Event.DispatchEvent(ModuleId.CHAT, gmodule.notifyId.Chat.ReplayKit, {
    status = instance.m_Status
  })
end
def.static().OnAwake = function()
  warn("ECReplayKit OnAwake")
  if not instance or instance.m_TimerID ~= 0 then
    warn("Muliti click BeginBroadcast")
    return
  end
  instance.m_TimerID = GameUtil.AddGlobalTimer(15, true, function()
    warn("BeginBroadcast Timeout and StopBroadcast~~~~~~~~~", instance.m_Status)
    Toast(textRes.Common[312])
    if instance.m_Status ~= ECReplayKit.STATUS.START then
      instance.m_Status = ECReplayKit.STATUS.STOP
      ECReplayKit.StopBroadcast()
    end
  end)
end
def.static("=>", "boolean").IsSupportReplayLive = function()
  if ReplayKit and ReplayKit.isSupportReplayLive then
    return ReplayKit.isSupportReplayLive()
  end
  return true
end
def.static("boolean", "boolean").BeginBroadcast = function(openMic, openCamera)
  if not ECReplayKit.IsSupportReplayLive() then
    Toast(textRes.Common[314])
    return
  end
  local ECApollo = require("ProxySDK.ECApollo")
  if ECApollo.GetStatus() ~= 0 then
    Toast(textRes.Chat.ApolloError[12])
    return
  end
  ECReplayKit.BeginBroadcastInner(openMic, openCamera)
end
def.static().StopBroadcast = function()
  if not ECReplayKit.IsSupportReplayLive() then
    return
  end
  if ReplayKit and ReplayKit.stopBroadcast then
    ReplayKit.stopBroadcast()
  end
  ECReplayKit.ClearTimer()
end
def.static().ResumeBroadcast = function()
  if ReplayKit and ReplayKit.resumeBroadcast and ECReplayKit.IsSupportReplayLive() then
    ReplayKit.resumeBroadcast()
  end
end
def.static().PauseBroadcast = function()
  if ReplayKit and ReplayKit.pauseBroadcast and ECReplayKit.IsSupportReplayLive() then
    ReplayKit.pauseBroadcast()
  end
end
def.static("boolean").SetupCamera = function(ison)
  if ReplayKit and ReplayKit.setupCamera then
    ReplayKit.setupCamera(ison)
  end
end
def.static("boolean").SetupMicrophone = function(ison)
  if ReplayKit and ReplayKit.setupMicrophone then
    ReplayKit.setupMicrophone(ison)
  end
end
def.static().IsPaused = function()
  if ReplayKit and ReplayKit.isPaused then
    ReplayKit.isPaused()
  end
end
def.static().IsBroadcasting = function()
  if ReplayKit and ReplayKit.isBroadcasting then
    ReplayKit.isBroadcasting()
  end
end
def.static("boolean", "boolean").BeginBroadcastInner = function(openMic, openCamera)
  if not instance then
    return
  end
  if ReplayKit and ReplayKit.beginBroadcast then
    ReplayKit.beginBroadcast(openMic, openCamera)
  end
end
def.static("boolean").EnableSoftAec = function(enable)
  if Apollo.EnableSoftAec then
    Apollo.EnableSoftAec(enable)
  else
    Debug.LogWarning("Apollo.EnableSoftAec Does not Exitst")
  end
end
def.static().InitReplayKit = function()
  if ReplayKit and ReplayKit.initBroadcast then
    local callback = {
      onStart = ECReplayKit.OnStart,
      onStop = ECReplayKit.OnStop,
      onAwake = ECReplayKit.OnAwake
    }
    ReplayKit.initBroadcast(callback)
  end
end
def.static("=>", "number").GetStatus = function()
  if not instance then
    return ECReplayKit.STATUS.NON
  end
  return instance.m_Status
end
def.static("=>", "boolean").GetCurrentMicState = function()
  if not instance then
    return false
  end
  return instance.m_MicState
end
def.static("boolean").SetMicState = function(state)
  if not instance then
    return
  end
  instance.m_MicState = state
end
def.static().ClearTimer = function()
  if instance and instance.m_TimerID ~= 0 then
    GameUtil.RemoveGlobalTimer(instance.m_TimerID)
    instance.m_TimerID = 0
  end
end
def.method().Init = function(self)
  ECReplayKit.InitReplayKit()
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, function()
    warn("ECReplayKit LEAVE_WORLD StopBroadcast")
    if platform == 1 then
      ECReplayKit.StopBroadcast()
    end
  end)
end
ECReplayKit.Commit()
return ECReplayKit
