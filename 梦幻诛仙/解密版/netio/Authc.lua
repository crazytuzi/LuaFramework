local Authc = {}
local loginInfo = {loginType = 0, authcOk = false}
local protoMgr = require("netio.ProtocolManager")
local Lplus = require("Lplus")
local ECGame = Lplus.ForwardDeclare("ECGame")
local netData = require("netio.netdata")
local checkTime = 0
local LOGIN_TYPE_NORMAL = netData.LOGIN_TYPE_NORMAL
local LOGIN_TYPE_SDK = netData.LOGIN_TYPE_SDK
local LOGIN_TYPE_TOKEN = netData.LOGIN_TYPE_TOKEN
local LOGIN_TYPE_CROSSSERVER = netData.LOGIN_TYPE_CROSSSERVER
local function checkTimeout(time)
  if _G.IsReplayNetIO then
    return false
  end
  return time <= os.time() - checkTime
end
Authc.lastProtocolUpdateTime = 0
function Authc.getLoginType()
  return loginInfo.loginType
end
function Authc.getLoginToken()
  return loginInfo.pwd
end
function Authc.haveToken()
  return loginInfo.loginType == LOGIN_TYPE_TOKEN
end
function Authc.setServerInfo(ip, port)
  loginInfo.ip = ip
  loginInfo.port = port
  printInfo("*LUA* select server : %s %s", loginInfo.ip, loginInfo.port)
end
function Authc.setAccountInfo(user, pwd, loginType)
  loginInfo.loginType = loginType
  if loginType == LOGIN_TYPE_TOKEN then
    loginInfo.user = user or loginInfo.user
    loginInfo.pwd = pwd
  else
    local Octets = require("netio.Octets")
    loginInfo.user = type(user) == "string" and Octets.rawFromString(user) or user
    loginInfo.pwd = type(pwd) == "string" and Octets.rawFromString(pwd) or pwd
  end
end
function Authc.startup()
  if not protoMgr.startup(require("netio.ConnectHandler").new()) then
    print("*LUA* Error to startup")
    return
  end
  local timerID = GameUtil.AddGlobalTimer(0.05, false, Authc.update)
  local timerID2 = GameUtil.AddGlobalTimer(5, false, Authc.keepAliveTimer)
end
function Authc.resetLoginInfo()
  loginInfo.loginType = __NetIOGetLoginType()
  loginInfo.user = nil
  loginInfo.pwd = nil
  loginInfo.userid = nil
  loginInfo.localsid = nil
  loginInfo.remain_time = nil
  loginInfo.zoneid = nil
  loginInfo.aid = nil
  loginInfo.algorithm = nil
end
function Authc.disConnect()
  Authc.setAuthcFailed()
  protoMgr.disconnect()
end
function Authc.update()
  Authc._update()
end
function Authc.protocolUpdate()
  protoMgr.checkconnect()
  if protoMgr.isconnected() then
    if protoMgr.update() then
      Authc.lastProtocolUpdateTime = os.time()
    end
  else
    Authc._update = Authc.emptyUpdate
  end
end
function Authc.emptyUpdate()
end
local function loginServer()
  netData.setGameStatus(netData.GNET_STATUS_LOGIN)
  local ret = protoMgr.connect(loginInfo.ip, loginInfo.port, loginInfo.user, loginInfo.pwd)
  Authc._update = Authc.checkConnectBegin
  checkTime = os.time()
  print("*LUA* socket connect ret :", ret)
  if ret then
    return true
  end
  print("\232\191\158\230\142\165\230\156\141\229\138\161\229\153\168\229\164\177\232\180\165ret :", ret)
  return false
end
function Authc.login()
  protoMgr.checkconnect()
  if not protoMgr.isconnected() then
    loginServer()
  else
    print("socket connect error!")
    Authc.checkCloseConnectBegin()
  end
end
function Authc.loginForToken()
  if Authc.haveToken() then
    Authc.login()
  end
end
function Authc.registerProtocol()
  local func = protoMgr.RegisterModuleProtocol
  func(require("netio.protocol.gnet.KeepAlive").TYPEID, Authc.onKeepAlive)
  func(require("netio.protocol.gnet.Challenge").TYPEID, Authc.onChallenge)
  func(require("netio.protocol.gnet.ErrorInfo").TYPEID, Authc.onErrorInfo)
  func(require("netio.protocol.gnet.KeyExchange").TYPEID, Authc.onKeyExchange)
  func(require("netio.protocol.gnet.OnlineAnnounce").TYPEID, Authc.onOnlineAnnounce)
  func(require("netio.protocol.gnet.NotifyResourceVersionInfo").TYPEID, Authc.onNotifyResourceVersionInfo)
end
function Authc.keepAliveTimer()
  local keepAlive = require("netio.protocol.gnet.KeepAlive").new(1)
  protoMgr.checkconnect()
  if protoMgr.isconnected() and loginInfo.authcOk then
    keepAlive.code = os.time()
    if Authc.lastProtocolUpdateTime == 0 then
      Authc.lastProtocolUpdateTime = keepAlive.code
    end
    local time = keepAlive.code - Authc.lastProtocolUpdateTime
    if time > 30 then
      print("KeepAlive bak time > 30, \232\135\170\229\138\168\230\150\173\229\188\128\231\189\145\231\187\156\233\147\190\230\142\165 !!!!!!!", time)
      Authc.lastProtocolUpdateTime = 0
      Authc.disConnect()
    else
      protoMgr.sendProtocol(keepAlive)
    end
  end
end
function Authc.onKeepAlive(p)
end
function Authc.onChallenge(p)
  local network = require("netio.Network")
  print("*LUA* Protocol Challenge Dump Begin")
  print("*LUA* id = " .. p.id)
  print("*LUA* nonce =", tostring(p.nonce))
  print("*LUA* version = " .. p.version)
  print("*LUA* serverattr.flags = " .. p.serverattr.flags)
  print("*LUA* serverattr.load = " .. p.serverattr.load)
  for k, v in pairs(p.serverattr.extra) do
    print("*LUA* serverattr.extra.key = " .. k .. " serverattr.extra.value = " .. v)
  end
  p.resource_versions = p.resource_versions or {}
  for k, v in pairs(p.resource_versions) do
    print("*LUA* resource_versions.key = " .. k .. " resource_versions.value = " .. v)
  end
  print("*LUA* Protocol Challenge Dump End")
  netData.setProtocolVersion(p.version)
  netData.setGameStatus(netData.GNET_STATUS_CHALLENGE)
  local localVersion = ECGame.Instance():getClientVersion()
  local resourceUpdateMgr = require("Main.Update.ResourceUpdateMgr").Instance()
  local rvkey = resourceUpdateMgr:GetResourceVersionKey()
  local cvkey = resourceUpdateMgr:GetCompatiableVersionKey()
  local resourceVersion = p.resource_versions[rvkey] or 0
  local compatiableVersion = p.resource_versions[cvkey] or 0
  resourceUpdateMgr:SetResourceVersion(resourceVersion, compatiableVersion)
  if resourceUpdateMgr:CheckForceUpdate() then
    return
  end
  localVersion = 0
  if localVersion > 0 and localVersion < p.version then
    gmodule.network.disConnect()
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
    require("GUI.CommonConfirmDlg").ShowCerternConfirm(textRes.Common[52], textRes.Common[50], textRes.Common[51], function(i, tag)
      require("Main.Login.LoginModule").Instance():Back2Login()
    end, {id = self})
    return
  end
  network.connectLink()
  local loginArg = require("Main.Login.LoginUtility").GetLoginArg()
  local Json = require("Utility.json")
  local Octets = require("netio.Octets")
  local identity = loginInfo.user
  local response
  local loginType = loginInfo.loginType
  local mid = Octets.raw()
  local extra = Octets.rawFromString(Json.encode(loginArg))
  local reserved1 = 0
  local reserved2 = 0
  local reserved3 = 0
  local reserved4 = Octets.raw()
  print("*LUA* Sending Protocol Response")
  if loginType == netData.LOGIN_TYPE_SDK or loginType == netData.LOGIN_TYPE_NO_AUTH then
    response = loginInfo.pwd
  else
    response = __NetIO_HMACMD5(p.nonce)
  end
  print(string.format("login type:%d", loginType))
  local protoObj = require("netio.protocol.gnet.Response").new(identity, response, loginType, mid, extra, reserved1, reserved2, reserved3, reserved4)
  protoMgr.sendProtocol(protoObj)
end
function Authc.onErrorInfo(p)
  print("*LUA* Protocol ErrorInfo Dump Begin")
  local errcode = p.errcode
  local errorInfo = _G.GetStringFromOcts and _G.GetStringFromOcts(p.info) or tostring(p.info)
  printInfo("onErrorInfo: %d (%s)", errcode, errorInfo)
  gmodule.network.onNetErrorInfo(errcode, errorInfo)
  print("*LUA* Protocol ErrorInfo Dump End")
end
function Authc.onKeyExchange(p)
  print("*LUA* Protocol KeyExchange Dump Begin")
  print("*LUA* nonce =", tostring(p.nonce))
  print("*LUA* blkickuser = " .. p.blkickuser)
  print("*LUA* Protocol KeyExchange Dump End")
  netData.setGameStatus(netData.GNET_STATUS_KEYEXCHANGE)
  loginInfo.iskickuser = 1
  local nonce = __NetIO_SetupSecurityKey(p.nonce, loginInfo.loginType)
  print("onKeyExchange = ", tostring(nonce))
  local blkickuser = loginInfo.iskickuser
  local protoObj = require("netio.protocol.gnet.KeyExchange").new(nonce, blkickuser)
  protoMgr.sendProtocol(protoObj)
end
function Authc.onOnlineAnnounce(p)
  local network = require("netio.Network")
  print("*LUA* Protocol OnlineAnnounce Dump Begin")
  print("*LUA* id = " .. p.id)
  print("*LUA* userid = " .. __NetIO_OctetsToString(p.userid))
  print("*LUA* localsid = " .. p.localsid)
  print("*LUA* remain_time = " .. p.remain_time)
  print("*LUA* zoneid = " .. p.zoneid)
  print("*LUA* aid = " .. p.aid)
  print("*LUA* algorithm = " .. p.algorithm)
  warn("*LUA* reconnect_token = " .. tostring(p.reconnect_token))
  print("*LUA* Protocol OnlineAnnounce Dump End")
  local userid = _G.GetStringFromOcts(p.userid)
  local _, _, capture = userid:find(".+@(%d+)$")
  local zoneid = p.zoneid
  if capture then
    zoneid = tonumber(capture)
  end
  warn(zoneid, "#################################", _G.GetStringFromOcts(p.userid))
  netData.setGameStatus(netData.GNET_STATUS_SUCCESS)
  loginInfo.authcOk = true
  loginInfo.userid = p.userid
  loginInfo.localsid = p.localsid
  loginInfo.remain_time = p.remain_time
  loginInfo.zoneid = zoneid
  loginInfo.aid = p.aid
  loginInfo.algorithm = p.algorithm
  loginInfo.pwd = p.reconnect_token
  network.authcOk()
  network.m_zoneid = loginInfo.zoneid
  network.m_aid = loginInfo.aid
  network.m_mainZoneId = p.zoneid
  local sdktype = ClientCfg.GetSDKType()
  if sdktype == ClientCfg.SDKTYPE.MSDK then
    local ECMSDK = require("ProxySDK.ECMSDK")
    local flag = ECMSDK.RegisterMidas(ClientCfg.GetCfgEnv())
    if not flag then
      Debug.LogError("RegisterMidas fail")
    end
    warn(ClientCfg.GetCfgEnv(), "RegisterMidas------------------:", flag)
  end
end
function Authc.onNotifyResourceVersionInfo(p)
  local clientResourceType = platform + 1
  if clientResourceType ~= p.resource_type then
    return
  end
  local ResourceUpdateMgr = require("Main.Update.ResourceUpdateMgr")
  ResourceUpdateMgr.Instance():SetResourceVersion(p.version, p.compatible_version)
  if not ResourceUpdateMgr.Instance():CheckForceUpdate() then
    ResourceUpdateMgr.Instance():CheckToShowUpdateConfirm()
  end
end
function Authc.setAuthcFailed()
  loginInfo.authcOk = false
end
function Authc.checkConnectBegin()
  print("[Authc.checkConnectBegin]")
  checkTime = os.time()
  Authc._update = Authc.checkConnectUpdate
end
function Authc.checkConnectUpdate()
  protoMgr.checkconnect()
  if protoMgr.isconnected() or protoMgr.issessionabort() or protoMgr.issessiondel() or checkTimeout(10) then
    Authc._update = Authc.emptyUpdate
    Authc.checkConnectEnd()
  end
end
function Authc.checkConnectEnd()
  print("[Authc.checkConnectEnd]", protoMgr.isconnected())
  if protoMgr.isconnected() then
    Authc.checkGNetBegin()
  else
    gmodule.network.disConnect()
    gmodule.network.onAbort()
  end
end
function Authc.checkGNetBegin()
  print("[Authc.checkGNetBegin]")
  checkTime = os.time()
  Authc._update = Authc.checkGNetUpdate
end
function Authc.checkGNetUpdate()
  Authc.protocolUpdate()
  if loginInfo.authcOk or checkTimeout(10) then
    Authc._update = Authc.emptyUpdate
    Authc.checkGNetEnd()
  end
end
function Authc.checkGNetEnd()
  print("[Authc.checkGNetEnd]", loginInfo.authcOk)
  if loginInfo.authcOk then
    if loginInfo.loginType == LOGIN_TYPE_TOKEN then
      Authc.checkEnterGameBegin()
    else
      loginInfo.loginType = LOGIN_TYPE_TOKEN
      Authc.checkRoleInfoOkBegin()
    end
  else
    gmodule.network.disConnect()
    local Network = require("netio.Network")
    if loginInfo.loginType == LOGIN_TYPE_TOKEN and netData.getStatus() >= netData.GNET_STATUS_CHALLENGE then
      gmodule.network.onConnectError(Network.ConnectError.TOKEN_EXPIRE_ERR)
    else
      gmodule.network.onAbort(Network.ConnectError.TIMEOUT)
    end
  end
end
function Authc.checkRoleInfoOkBegin()
  print("[Authc.checkRoleInfoOkBegin]")
  checkTime = os.time()
  Authc._update = Authc.checkRoleInfoOkUpdate
end
function Authc.checkRoleInfoOkUpdate()
  Authc.protocolUpdate()
  if netData.isRoleInfoOk() or checkTimeout(10) then
    Authc._update = Authc.emptyUpdate
    Authc.checkRoleInfoOkEnd()
  end
end
function Authc.checkRoleInfoOkEnd()
  print("[Authc.checkRoleInfoOkEnd]", netData.isRoleInfoOk())
  if netData.isRoleInfoOk() then
    Authc._update = Authc.protocolUpdate
  else
    gmodule.network.disConnect()
    local Network = require("netio.Network")
    gmodule.network.onAbort(Network.ConnectError.TIMEOUT)
  end
end
function Authc.checkEnterGameBegin()
  print("[Authc.checkEnterGameBegin]")
  checkTime = os.time()
  Authc._update = Authc.checkEnterGameUpdate
end
function Authc.checkEnterGameUpdate()
  Authc.protocolUpdate()
  if netData.isEnterGame() or checkTimeout(15) then
    Authc._update = Authc.emptyUpdate
    Authc.checkEnterGameEnd()
  end
end
function Authc.checkEnterGameEnd()
  print("[Authc.checkEnterGameEnd]", netData.isEnterGame())
  if netData.isEnterGame() then
    Authc._update = Authc.protocolUpdate
  else
    gmodule.network.disConnect()
    local Network = require("netio.Network")
    gmodule.network.onAbort(Network.ConnectError.TIMEOUT)
  end
end
function Authc.checkCloseConnectBegin()
  print("[Authc.checkCloseConnectBegin]")
  checkTime = os.time()
  Authc._update = Authc.closeConnectUpdate
end
function Authc.closeConnectUpdate()
  protoMgr.checkconnect()
  if not protoMgr.isconnected() or checkTimeout(3) then
    Authc._update = Authc.emptyUpdate
    Authc.checkCloseConnectEnd()
  end
end
function Authc.checkCloseConnectEnd()
  print("[Authc.checkCloseConnectEnd]", protoMgr.isconnected())
  gmodule.network.ClearProtocols()
  if not protoMgr.isconnected() then
    loginServer()
  else
    gmodule.network.disConnect()
    gmodule.network.onAbort()
  end
end
function Authc.setProtocolUpdate()
  Authc._update = Authc.protocolUpdate
end
Authc._update = Authc.emptyUpdate
return Authc
