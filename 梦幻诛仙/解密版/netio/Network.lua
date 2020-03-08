local Network = {}
local ModuleManager = require("Main.module.ModuleMgr")
local authc = require("netio.Authc")
local protoMgr = require("netio.ProtocolManager")
local GSPConst = require("netio.protocol.mzm.gsp.Const")
local protocolBuff
local inGame = false
local modules = {}
local autoConnect = {
  status = false,
  canAuto = false,
  svrReturn = false,
  count = 0,
  lastConnectTime = 0,
  retryTimes = 2,
  retryInterval = 3,
  onTimeout = nil
}
local confirmDlg
Network.ConnectError = {
  Abort = 0,
  PARAM_ERR = 1,
  TOKEN_EXPIRE_ERR = 2,
  TIMEOUT = 3
}
Network.connectLinkHandler = nil
Network.connectLostHandler = nil
Network.connectErrorHandler = nil
Network.netErrorHandler = nil
Network.authcOkHandler = nil
Network.m_lastSendProtocols = nil
Network.m_lastRecvProtocols = nil
Network.m_lastSendProtocolIdx = 1
Network.m_lastRecvProtocolIdx = 1
Network.m_zoneid = 0
Network.m_aid = 0
Network.m_mainZoneId = 0
function Network.registerProtocol(protoName, func)
  local p = require(protoName)
  if not p then
    print(string.foramt("[Module] register protocol : name error ! name = %s", protoName))
    return
  end
  protoMgr.RegisterModuleProtocol(p.TYPEID, func)
end
function Network.registerProtocolEx(protoName, obj, func)
  if type(obj) ~= "table" then
    print(string.format("[Module] register protocol: obj type error ! name = [%s] type=%s", protoName, type(obj)))
    return
  end
  if type(func) ~= "function" then
    print(string.format("[Module] register protocol: function type error ! name=%s, type = %s", protoName, type(func)))
    return
  end
  return Network.registerProtocol(protoName, function(p)
    func(obj, p)
  end)
end
function Network.dispatchProtocol(callback, protoObj)
  for _, f in ipairs(callback) do
    if _G.isDebugBuild then
      GameUtil.BeginSamp("dispatchProtocol " .. FormatFunctionInfo(f))
    end
    if Network.m_lastRecvProtocols == nil then
      Network.m_lastRecvProtocols = {}
    end
    if Network.m_lastRecvProtocolIdx >= 5 then
      Network.m_lastRecvProtocolIdx = 1
    else
      Network.m_lastRecvProtocolIdx = Network.m_lastRecvProtocolIdx + 1
    end
    Network.m_lastRecvProtocols[Network.m_lastRecvProtocolIdx] = protoObj.__cname
    f(protoObj)
    if _G.isDebugBuild then
      GameUtil.EndSamp()
    end
  end
end
function Network.sendProtocol(protoObj)
  if protoMgr.isconnected() then
    protoMgr.sendProtocol(protoObj)
    if Network.m_lastSendProtocols == nil then
      Network.m_lastSendProtocols = {}
    end
    if Network.m_lastSendProtocolIdx >= 5 then
      Network.m_lastSendProtocolIdx = 1
    else
      Network.m_lastSendProtocolIdx = Network.m_lastSendProtocolIdx + 1
    end
    Network.m_lastSendProtocols[Network.m_lastSendProtocolIdx] = protoObj.__cname
  end
end
function Network.networkStartup()
  authc.startup()
  authc.registerProtocol()
end
function Network.isconnected()
  return protoMgr.isconnected()
end
function Network.disConnect()
  authc.setAuthcFailed()
  protoMgr.resetConnectStatus(false)
  __NetIO_Disconnect()
  Network.ClearProtocols()
end
function Network.getLoginToken()
  return authc.getLoginToken()
end
function Network.isAutoConnect()
  return autoConnect.status
end
function Network.autoConnect(onTimeout)
  if autoConnect.canAuto then
    print("connecting...")
    autoConnect.status = true
    autoConnect.svrReturn = false
    autoConnect.count = 0
    autoConnect.onTimeout = onTimeout
    autoConnect.lastConnectTime = os.time()
    authc.loginForToken()
  end
end
function Network.setServerInfo(ip, port)
  authc.setServerInfo(ip, port)
end
function Network.setAccountInfo(userid, passwd, loginType)
  authc.setAccountInfo(userid, passwd, loginType)
end
function Network.authcOk()
  print("authc ok")
  autoConnect.canAuto = true
  if Network.authcOkHandler then
    Network.authcOkHandler()
  end
end
function Network.login()
  authc.login()
end
function Network.loginForToken()
  authc.loginForToken()
end
function Network.onAutoConnect()
  if autoConnect.status then
    if autoConnect.svrReturn then
      autoConnect.status = false
      autoConnect.svrReturn = false
    elseif autoConnect.count < autoConnect.retryTimes then
      autoConnect.count = autoConnect.count + 1
      autoConnect.lastConnectTime = os.time()
      authc.loginForToken()
    else
      autoConnect.funcHandle = nil
      autoConnect.canAuto = false
      autoConnect.status = false
      autoConnect.count = 0
      if autoConnect.onTimeout then
        autoConnect.onTimeout()
      end
    end
  end
end
function Network.setCanAuto(canAuto)
  autoConnect.canAuto = canAuto
end
function Network.checkRoleInfoOk()
  authc.checkRoleInfoOkBegin()
end
function Network.resumeProtocolUpdate()
  authc.setProtocolUpdate()
end
function Network.connectLink()
  if autoConnect.status then
    autoConnect.svrReturn = true
    autoConnect.status = false
  end
  if Network.connectLinkHandler ~= nil then
    Network.connectLinkHandler()
  end
end
function Network.onConnectLost()
  autoConnect.svrReturn = false
  authc.setAuthcFailed()
  Network.ClearProtocols()
  if Network.connectLostHandler ~= nil then
    Network.connectLostHandler()
  end
end
function Network.onAbort(errcode)
  if Network.isAutoConnect() then
    if autoConnect.count < autoConnect.retryTimes then
      local curTime = os.time()
      local period = curTime - autoConnect.lastConnectTime
      local interval = autoConnect.retryInterval
      if period < interval then
        GameUtil.AddGlobalTimer(interval - period, true, Network.onAutoConnect)
      else
        local skipConnectCount = math.floor(period / autoConnect.retryInterval) - 1
        autoConnect.count = autoConnect.count + skipConnectCount
        Network.onAutoConnect()
      end
    else
      Network.onAutoConnect()
    end
  else
    errcode = errcode or Network.ConnectError.Abort
    if Network.connectErrorHandler ~= nil then
      Network.connectErrorHandler(errcode)
    end
  end
end
function Network.onDel()
  Network.onAbort()
end
function Network.onConnectError(errcode)
  errcode = errcode or Network.ConnectError.PARAM_ERR
  autoConnect.svrReturn = false
  authc.setAuthcFailed()
  if Network.connectErrorHandler ~= nil then
    Network.connectErrorHandler(errcode)
  end
end
function Network.onNetErrorInfo(errcode, errorInfo)
  if errcode == GSPConst.ERR_FORCE_RECONNECT then
    authc.disConnect()
    return
  end
  inGame = false
  autoConnect.svrReturn = false
  if autoConnect.status then
    autoConnect.status = false
  end
  autoConnect.canAuto = false
  authc.resetLoginInfo()
  if Network.netErrorHandler ~= nil then
    Network.netErrorHandler(errcode, errorInfo)
  end
end
function Network.ClearProtocols()
  __NetIO_Clear()
end
return Network
