SanQiAndMgr = class("SanQiAndMgr", ChannelClassBase)
SanQiAndMgr.cls_and = "com/nomoga/channel/SY37Inter"
SanQiAndMgr.m_appid = "1001715"
SanQiAndMgr.m_appkey = "aZn3WP-DdlsTLMqyjVXYxr6ecf&UzJtC"
SanQiAndMgr.m_paykey = "lH3urgaF8fwh21pySCMnZX90tJ/q4bx!"
SanQiAndMgr.m_callbackurl = ""
function SanQiAndMgr:ctor()
  self.m_loginfo = {}
  self.m_Listener = nil
  self.m_IsLoginSucceedCallback = false
  print(" ======>>>>>>>> SanQiAndMgr.ctor ")
  callStaticMethodJava(SanQiAndMgr.cls_and, "setMessageListener", {
    handler(self, self.MessageCallBack)
  })
end
function SanQiAndMgr:MessageCallBack(param, isSucceed)
  dump(param, " SanQiAndMgr ======>> param ")
  local rbtype = param.type
  if rbtype == 1 then
    self:_callback(ChannelCallbackStatus.kInitSuccess)
  elseif rbtype == 2 then
    self:_callback(ChannelCallbackStatus.kInitFail)
  elseif rbtype == 11 then
    self.m_loginfo = {}
    self.m_loginfo.token = param.token
    self.m_loginfo.gid = param.gid
    self.m_loginfo.pid = param.pid
    if param.token == nil or param.gid == nil or param.pid == nil then
      self:_callback(ChannelCallbackStatus.kLogoutFail)
      return
    end
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
  elseif rbtype == 12 then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  elseif rbtype == 21 then
    self:_callback(ChannelCallbackStatus.kLogoutSuccess)
  elseif rbtype == 22 then
    self:_callback(ChannelCallbackStatus.kLogoutFail)
  elseif rbtype == 51 then
    self.m_loginfo = {}
    self.m_loginfo.token = param.token
    self.m_loginfo.gid = param.gid
    self.m_loginfo.pid = param.pid
    if param.token == nil or param.gid == nil or param.pid == nil then
      self:_callback(ChannelCallbackStatus.kAccountSwitchFail)
      return
    end
    self:_callback(ChannelCallbackStatus.kAccountSwitchSuccess)
  elseif rbtype == 52 then
    self:_callback(ChannelCallbackStatus.kAccountSwitchFail)
  elseif rbtype == 31 then
    self:_callback(ChannelPayResult.kPaySucceed)
    self:aftetPay()
  elseif rbtype == 32 then
    self:_callback(ChannelPayResult.kPayFailed)
    self:aftetPay()
  elseif rbtype == 41 then
    self:callExitGame_(1)
  elseif rbtype == 42 then
    self:callExitGame_(0)
  end
end
function SanQiAndMgr:_callback(code, param)
  print("--->> _callback1:", self.m_Listener, code, param)
  if self.m_Listener ~= nil then
    print("--->> _callback2:", code, param)
    self.m_Listener(code, param)
  else
    print("--->> self.m_Listener = nil")
  end
end
function SanQiAndMgr:aftetPay()
  if self.payingSoundHandler then
    scheduler.unscheduleGlobal(self.payingSoundHandler)
    self.payingSoundHandler = nil
  end
  self.payingSoundHandler = scheduler.performWithDelayGlobal(function()
    soundManager.OnEnterForeroundFlush()
    soundManager.setIsPlayingVideo(false)
    soundManager.resumeSoundTemp()
  end, 1)
end
function SanQiAndMgr:Init(gameParam, listener)
  self.m_Listener = listener
  local ok, ret = callStaticMethodJava(SanQiAndMgr.cls_and, "InitSDK", {
    SanQiAndMgr.m_appkey
  }, "(Ljava/lang/String;)Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kInitFail)
  end
end
function SanQiAndMgr:Login()
  print("=======>>>>>> SanQiAndMgr:Login")
  self.m_IsLoginSucceedCallback = false
  local ok, ret = callStaticMethodJava(SanQiAndMgr.cls_and, "Login", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function SanQiAndMgr:LogOut()
  local ok, ret = callStaticMethodJava(SanQiAndMgr.cls_and, "Logout", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLogoutFail)
  end
end
function SanQiAndMgr:requestExitGame(listener)
  self.m_ExitGameListener = listener
  local ok, ret = callStaticMethodJava(SanQiAndMgr.cls_and, "exitSDK", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:callExitGame_(1)
  return false
end
function SanQiAndMgr:callExitGame_(result)
  local listener = self.m_ExitGameListener
  self.m_ExitGameListener = nil
  if listener then
    listener(result)
  end
end
function SanQiAndMgr:startPay(payParam)
  payParam = payParam or {}
  if payParam.amount == nil or payParam.amount <= 0 then
    self:_callback(ChannelPayResult.kPayFailed)
    return
  end
  soundManager.setIsPlayingVideo(true)
  soundManager.DisabledSoundTemp()
  if payParam.roleLv == nil or 0 >= payParam.roleLv then
    payParam.roleLv = 1
  end
  if payParam.cbid == nil then
    local strnum = string.sub(string.reverse(tostring(os.time())), 1, 6)
    math.randomseed(tonumber(strnum))
    local endNum = tostring(math.random(1, 1000000000))
    local headNum = tostring(os.date("%Y%m%d%H%M%S", os.time()))
    payParam.cbid = string.format("%s-%s-%s", headNum, payParam.roleId, endNum)
  end
  local sendParam = {
    payParam.cbid,
    payParam.payDataName,
    "元宝",
    getSubNumberFromString(payParam.serverId),
    payParam.serverName,
    payParam.customInfo,
    payParam.roleId,
    payParam.roleName,
    payParam.roleLv,
    payParam.amount,
    10
  }
  local ok, ret = callStaticMethodJava(SanQiAndMgr.cls_and, "startPay", sendParam, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;IFI)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:_callback(ChannelPayResult.kPayFailed)
  return false
end
function SanQiAndMgr:isLogined()
  return self.m_loginfo ~= nil and self.m_loginfo.gid ~= nil
end
function SanQiAndMgr:createRole(roleParam)
  if roleParam == nil then
    roleParam = {}
  end
  if roleParam.serverId == nil then
    roleParam.serverId = "1"
  end
  local getsid = string.gmatch(roleParam.serverId, "%d+")
  local mserverId = getsid()
  local ok, ret = callStaticMethodJava(SanQiAndMgr.cls_and, "createRole", {mserverId}, "(Ljava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function SanQiAndMgr:sendRoleInfoAfterLogin(roleParam)
  if roleParam == nil then
    roleParam = {}
  end
  if roleParam.roleLv == nil or roleParam.roleLv <= 0 then
    roleParam.roleLv = 1
  end
  if roleParam.serverId == nil then
    roleParam.serverId = "1"
  end
  local ok, ret = callStaticMethodJava(SanQiAndMgr.cls_and, "subRoleInfo", {
    tostring(getSubNumberFromString(roleParam.serverId)),
    roleParam.serverName,
    roleParam.roleId,
    roleParam.roleName,
    tostring(roleParam.roleLv),
    tostring(roleParam.balance),
    roleParam.bpName,
    tostring(roleParam.viplv)
  }, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function SanQiAndMgr:setGameServer(serverParam)
end
function SanQiAndMgr:sendLoginProtocol(gameType, deveceType)
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  self.m_loginfo = self.m_loginfo or {}
  local token = self.m_loginfo.token
  if token == nil then
    print(" 37wan ============>>>>>>token is nil ")
    return
  end
  NetSend({
    s_gf = gameType,
    s_tkn = token,
    i_dtp = deveceType,
    t_v = ver
  }, S2C_Account, "P16")
end
function SanQiAndMgr:getDid()
  return 2
end
function SanQiAndMgr:Clean()
  self.m_Listener = nil
  self.m_loginfo = {}
  if self.payingSoundHandler then
    scheduler.unscheduleGlobal(self.payingSoundHandler)
    self.payingSoundHandler = nil
  end
end
return SanQiAndMgr
