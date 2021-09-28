LJAndroidMgr = class("LJAndroidMgr", ChannelClassBase)
LJAndroidMgr.cls_and = "com/nomoga/channel/LJInter"
LJAndroidMgr.SpecalLoginTimeOut = 5
LJAndroidMgr.UnitPrice = 10
LJAndroidMgr.CallBackUrl = "http://192.168.1.102:8001/lj/payed"
LJAndroidMgr.ItemName = "元宝"
LJAndroidMgr.PayType = 1
LJAndroidMgr.sepcialChannel = {
  "yyb",
  "oppo",
  "kugou",
  "baofeng2",
  "anzhi"
}
LJAndroidMgr.CheckPayNameChannel = {unicom_ = 1}
function LJAndroidMgr:ctor()
  self.m_IsLoginSucceedCallback = false
  self.m_Listener = nil
  self.m_ExitGameListener = nil
  self.m_Sid = nil
  self.m_channellabel = nil
  self.m_loginTimerHandler = nil
  self.m_logcounter = 0
  g_DataMgr.isPaying = false
  self.payingSoundHandler = nil
  callStaticMethodJava(LJAndroidMgr.cls_and, "setMessageListener", {
    handler(self, self.MessageCallBack)
  })
  self.m_switchCount = false
end
function LJAndroidMgr:Init(gameParam, listener)
  self.m_Listener = listener
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "InitSDK", {}, "()Ljava/lang/String;")
  print(" **********************  ok, ret  ", ok, ret)
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kInitFail)
  end
end
function LJAndroidMgr:isLogined()
  return self.m_Sid ~= nil
end
function LJAndroidMgr:getChannelLabel()
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "getChannelLabel", {}, "()Ljava/lang/String;")
  if ok == true then
    self.m_channellabel = ret
    return ret
  end
end
function LJAndroidMgr:getRealChannelId()
  local clb = self:getChannelLabel()
  if clb == nil then
    clb = SyNative.getAppChannelId()
  end
  return clb
end
function LJAndroidMgr:LoginTick()
  if self.m_logcounter > LJAndroidMgr.SpecalLoginTimeOut then
    if self.m_loginTimerHandler ~= nil then
      scheduler.unscheduleGlobal(self.m_loginTimerHandler)
      self.m_loginTimerHandler = nil
      self.m_logcounter = 0
      self:_callback(ChannelCallbackStatus.kLoginCancel)
      print("================>>>>>>>　LoginTick")
    end
  else
    self.m_logcounter = self.m_logcounter + 1
  end
end
function LJAndroidMgr:Login()
  print("====>>>>>   LJAndroidMgr:Login  self.m_switchCount = ", self.m_switchCount)
  if self.m_loginTimerHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_loginTimerHandler)
    self.m_loginTimerHandler = nil
    self.m_logcounter = 0
  end
  self.m_channellabel = self:getChannelLabel()
  if self.m_switchCount == true then
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
    self.m_switchCount = false
    return
  end
  print("====>>>>>   LJAndroidMgr:Login  self.m_switchCount = ", self.m_channellabel)
  if self.m_channellabel ~= nil and self.m_channellabel ~= "" then
    local isbc = false
    for k, v in pairs(LJAndroidMgr.sepcialChannel) do
      if v == self.m_channellabel then
        isbc = true
      end
    end
    if isbc == true then
      self.m_loginTimerHandler = scheduler.scheduleGlobal(handler(self, self.LoginTick), 1)
    end
  end
  self.m_IsLoginSucceedCallback = false
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "Login", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function LJAndroidMgr:LoginFinished_(isCloseLoginView)
  if self.m_loginTimerHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_loginTimerHandler)
    self.m_loginTimerHandler = nil
    self.m_logcounter = 0
  end
  self.m_Sid = self:getSid()
  print(" LJAndroidMgr:LoginFinished_   ", self.m_Sid)
  if self.m_Sid == "null" or self.m_Sid == "nil" then
    self.m_Sid = nil
  end
  if self.m_Sid == nil or self.m_Sid == "null" or self.m_IsLoginSucceedCallback ~= true then
    if isCloseLoginView == true then
      self:_callback(ChannelCallbackStatus.kLoginCancel)
    else
      self:_callback(ChannelCallbackStatus.kLoginFail)
    end
  else
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
  end
end
function LJAndroidMgr:getSid()
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "getSid", {}, "()Ljava/lang/String;")
  if ok == true then
    self.m_Sid = ret
    return ret
  end
end
function LJAndroidMgr:_callback(code, param)
  print("--->> _callback1:", self.m_Listener, code, param)
  if self.m_Listener ~= nil then
    print("--->> _callback2:", code, param)
    self.m_Listener(code, param)
  else
    print("--->> self.m_Listener = nil")
  end
end
function LJAndroidMgr:MessageCallBack(data, isSucceed)
  print("LJAndroidMgr:MessageCallBack:")
  dump(data, "data")
  local typ = data.type
  if typ == 1 then
    self:getChannelLabel()
    self:_callback(ChannelCallbackStatus.kInitSuccess)
  elseif typ == 2 then
    self:_callback(ChannelCallbackStatus.kInitFail)
  elseif typ == 11 then
    self.m_Sid = data.token
    self.m_Uid = data.userID
    self.m_Chl = data.channelLabel
    self.m_Pcode = data.productCode
    local switchAccountChannel = {unicom_ = 1, wandoujia = 1}
    if self:isLogined() and switchAccountChannel[self:getChannelLabel()] == 1 then
      self.m_switchCount = true
      self.m_IsLoginSucceedCallback = true
      self:_callback(ChannelCallbackStatus.kAccountSwitchSuccess)
    else
      self.m_IsLoginSucceedCallback = true
      self:LoginFinished_(true)
    end
  elseif typ == 12 then
    self:_callback(ChannelCallbackStatus.kLoginCancel)
  elseif typ == 13 then
  elseif typ == 3 then
    print("  LJ 退出帐号成功")
    self.m_switchCount = false
    self:_callback(ChannelCallbackStatus.kLogoutSuccess)
  elseif typ == 51 then
    print("LJ 充值成功")
    self:_callback(ChannelPayResult.kPaySucceed)
    self:aftetPay()
  elseif typ == 52 then
    print("LJ 充值失败, 没有初始化")
    self:_callback(ChannelPayResult.kPayFailed)
    self:aftetPay()
  elseif typ == 53 then
    print("LJ 充值界面关闭")
    self:_callback(ChannelPayResult.kPayViewClosed)
    self:aftetPay()
  elseif typ == 61 then
    print("LJ 退出游戏返回 继续游戏")
    self:callExitGame_(0)
  elseif typ == 62 then
    print("LJ 退出游戏返回 退出游戏")
    self:callExitGame_(1)
  end
end
function LJAndroidMgr:aftetPay()
  g_DataMgr.isPaying = false
  self.payingSoundHandler = scheduler.performWithDelayGlobal(function()
    soundManager.OnEnterForeroundFlush()
    soundManager.setIsPlayingVideo(false)
    soundManager.resumeSoundTemp()
  end, 1)
end
function LJAndroidMgr:Logout()
  self.m_switchCount = false
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "Logout", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLogoutFail)
  end
end
function LJAndroidMgr:sendLoginProtocol(gameType, deveceType)
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  print("=====================  LJAndroidMgr:sendLoginProtocol ", gameType, self.m_Sid, self.m_Uid, self.m_Chl, self.m_Pcode)
  NetSend({
    s_gf = gameType,
    s_tkn = self.m_Sid,
    s_userid = self.m_Uid,
    s_chl = self.m_Chl,
    s_pcode = self.m_Pcode,
    i_dtp = deveceType,
    t_v = ver,
    s_chn = channel.no,
    s_chnlb = self.m_channellabel
  }, S2C_Account, "P10")
end
function LJAndroidMgr:setGameServer(serverParam)
  if serverParam == nil then
    serverParam = {}
  end
  if serverParam.serverId == nil then
    serverParam.serverId = "1"
  end
  local getsid = string.gmatch(serverParam.serverId, "%d+")
  local mserverId = getsid()
  if serverParam.roleLv == nil or serverParam.roleLv <= 0 then
    serverParam.roleLv = 1
  end
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "setGameServer", {
    serverParam.roleId,
    serverParam.roleName,
    tostring(serverParam.roleLv),
    mserverId,
    serverParam.serverName,
    serverParam.bpName,
    serverParam.viplv,
    serverParam.balance
  }, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;II)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function LJAndroidMgr:sendRoleInfoAfterLogin(roleParam)
  return false
end
function LJAndroidMgr:createRole(roleParam)
  if roleParam == nil then
    roleParam = {}
  end
  if roleParam.serverId == nil then
    roleParam.serverId = "1"
  end
  local getsid = string.gmatch(roleParam.serverId, "%d+")
  local mserverId = getsid()
  if roleParam.roleLv == nil or roleParam.roleLv <= 0 then
    roleParam.roleLv = 1
  end
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "sendRoleInfoAfterLogin", {
    roleParam.roleId,
    roleParam.roleName,
    tostring(roleParam.roleLv),
    mserverId,
    roleParam.serverName,
    roleParam.bpName,
    roleParam.viplv,
    roleParam.balance
  }, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;II)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function LJAndroidMgr:RoleLevelUp(roleParam)
  if roleParam == nil then
    roleParam = {}
  end
  if roleParam.serverId == nil then
    roleParam.serverId = "1"
  end
  local getsid = string.gmatch(roleParam.serverId, "%d+")
  local mserverId = getsid()
  if roleParam.roleLv == nil or roleParam.roleLv <= 0 then
    roleParam.roleLv = 1
  end
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "LevelUp", {
    roleParam.roleId,
    roleParam.roleName,
    tostring(roleParam.roleLv),
    mserverId,
    roleParam.serverName,
    roleParam.bpName,
    roleParam.viplv,
    roleParam.balance
  }, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;Ljava/lang/String;II)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function LJAndroidMgr:requestExitGame(listener)
  self.m_ExitGameListener = listener
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "exitSDK", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:callExitGame_(1)
  return false
end
function LJAndroidMgr:callExitGame_(result)
  local listener = self.m_ExitGameListener
  self.m_ExitGameListener = nil
  if listener then
    listener(result)
  end
end
function LJAndroidMgr:Clean()
  self.m_Listener = nil
  self.m_ExitGameListener = nil
  if self.m_loginTimerHandler ~= nil then
    scheduler.unscheduleGlobal(self.m_loginTimerHandler)
    self.m_loginTimerHandler = nil
    self.m_logcounter = 0
  end
  if self.payingSoundHandler then
    scheduler.unscheduleGlobal(self.payingSoundHandler)
    self.payingSoundHandler = nil
  end
end
function LJAndroidMgr:hideToolBar()
end
function LJAndroidMgr:enterPersonCenter()
end
function LJAndroidMgr:showToolBar(place)
end
function LJAndroidMgr:startPay(payParam)
  print("  LJAndroidMgr:startPay   =========>>> payParam.amount = ", payParam.amount)
  if payParam == nil then
    self:_callback(ChannelPayResult.kPayFailed)
    return false
  end
  g_DataMgr.isPaying = true
  soundManager.setIsPlayingVideo(true)
  soundManager.DisabledSoundTemp()
  local itemName = payParam.itemName
  local count = payParam.defaultCount
  local clb = self:getChannelLabel()
  if LJAndroidMgr.CheckPayNameChannel[clb] == 1 then
    payParam.checkName = payParam.checkName or ""
    local si, ei = string.find(payParam.checkName, "节日礼包")
    if si and si > 0 then
      itemName = payParam.checkName or payParam.itemName
      count = 1
    else
      itemName = string.gsub(payParam.checkName, tostring(payParam.defaultCount), "")
    end
  end
  local sendParam = {
    LJAndroidMgr.PayType,
    itemName,
    payParam.amount * 100,
    payParam.UnitPrice * 100,
    count,
    payParam.customInfo,
    LJAndroidMgr.CallBackUrl
  }
  scheduler.performWithDelayGlobal(function()
    self:_callback(ChannelPayResult.kPayViewClosed)
  end, 5)
  local ok, ret = callStaticMethodJava(LJAndroidMgr.cls_and, "startPay", sendParam, "(ILjava/lang/String;FIFLjava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:_callback(ChannelPayResult.kPayFailed)
  return false
end
function LJAndroidMgr:getDid()
  return 2
end
return LJAndroidMgr
