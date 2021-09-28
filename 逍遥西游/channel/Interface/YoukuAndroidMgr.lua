local YoukuAndroidMgr = class("YoukuAndroidMgr", ChannelClassBase)
YoukuAndroidMgr.cls_and = "com/nomoga/channel/YoukuInter"
YoukuAndroidMgr.pay_callback_url = "http://192.168.1.102:8001/youku/payed"
function YoukuAndroidMgr:ctor()
  print("--->>> YoukuAndroidMgr init")
  self.m_Listener = nil
  self.m_ExitGameListener = nil
  self.m_UserInfo = {}
  callStaticMethodJava(YoukuAndroidMgr.cls_and, "setMessageListener", {
    handler(self, self.MessageCallBack)
  })
end
function YoukuAndroidMgr:_callback(code, param)
  print("--->> _callback1:", self.m_Listener, code, param)
  if self.m_Listener ~= nil then
    print("--->> _callback2:", code, param)
    self.m_Listener(code, param)
  else
    print("--->> self.m_Listener = nil")
  end
end
function YoukuAndroidMgr:MessageCallBack(data, isSucceed)
  print("YoukuAndroidMgr:MessageCallBack:")
  dump(data, "data")
  local typ = data.type
  if typ == 1 then
    self:_callback(ChannelCallbackStatus.kInitSuccess)
  elseif typ == 2 then
    self:_callback(ChannelCallbackStatus.kInitSuccess)
  elseif typ == 11 then
    self.m_UserInfo.session = data.session
    self.m_UserInfo.userName = data.userName
    dump(self.m_UserInfo, "self.m_UserInfo")
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
  elseif typ == 12 then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  elseif typ == 31 then
    print("优酷 退出帐号成功")
    self:_callback(ChannelCallbackStatus.kLogoutSuccess)
  elseif typ == 51 then
    print("UC 充值成功")
    self:_callback(ChannelPayResult.kPaySucceed)
  elseif typ == 52 then
    print("UC 充值失败")
    self:_callback(ChannelPayResult.kPayFailed)
  elseif typ == 61 then
    print("UC 退出游戏返回 继续游戏")
    self:callExitGame_(0)
  elseif typ == 62 then
    print("UC 退出游戏返回 退出游戏")
    self:callExitGame_(1)
  end
end
function YoukuAndroidMgr:Init(gameParam, listener)
  self.m_Listener = listener
  local ok, ret = callStaticMethodJava(YoukuAndroidMgr.cls_and, "InitSDK", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kInitFail)
  end
end
function YoukuAndroidMgr:isLogined()
end
function YoukuAndroidMgr:Login()
  local ok, ret = callStaticMethodJava(YoukuAndroidMgr.cls_and, "Login", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function YoukuAndroidMgr:sendLoginProtocol(gameType, deveceType)
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  NetSend({
    s_gf = gameType,
    s_tkn = self.m_UserInfo.session,
    i_dtp = deveceType,
    t_v = ver
  }, S2C_Account, "P15")
end
function YoukuAndroidMgr:getAccount()
  return self.m_UserInfo.session
end
function YoukuAndroidMgr:Logout()
  local ok, ret = callStaticMethodJava(YoukuAndroidMgr.cls_and, "Logout", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLogoutFail)
  end
end
function YoukuAndroidMgr:showToolBar(place)
  print([[


]])
  print("YoukuAndroidMgr:showToolBar")
  print([[


]])
  local ok, ret = callStaticMethodJava(YoukuAndroidMgr.cls_and, "showToolBar", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function YoukuAndroidMgr:hideToolBar()
  local ok, ret = callStaticMethodJava(YoukuAndroidMgr.cls_and, "hideToolBar", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function YoukuAndroidMgr:requestExitGame(listener)
  self.m_ExitGameListener = listener
  local ok, ret = callStaticMethodJava(YoukuAndroidMgr.cls_and, "exitSDK", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:callExitGame_(1)
  return false
end
function YoukuAndroidMgr:callExitGame_(result)
  local listener = self.m_ExitGameListener
  self.m_ExitGameListener = nil
  if listener then
    listener(result)
  end
end
function YoukuAndroidMgr:getDid()
  return 2
end
function YoukuAndroidMgr:Clean()
  self.m_Listener = nil
  self.m_ExitGameListener = nil
end
function YoukuAndroidMgr:startPay(payParam)
  local sendParam = {
    checkint(payParam.amount * 100),
    payParam.cbid,
    YoukuAndroidMgr.pay_callback_url,
    payParam.payDataName,
    payParam.customInfo
  }
  print("YoukuAndroidMgr:testPay ------  5")
  dump(sendParam, "sendParam")
  local ok, ret = callStaticMethodJava(YoukuAndroidMgr.cls_and, "startPay", sendParam, "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:_callback(ChannelPayResult.kPayFailed)
  return false
end
function YoukuAndroidMgr:testPay()
  print("YoukuAndroidMgr:testPay ------  1")
  scheduler.performWithDelayGlobal(function()
    for i = 1, 20 do
      print("\t\t 1 \n")
    end
    print("YoukuAndroidMgr:testPay ------  2")
    local payParam = {
      amount = 0.01,
      cbid = "payid000" .. tostring(os.time()),
      payDataName = "测试",
      customInfo = "gf=xiyou#kid=nmg_ios_3#rid=10826#gid=1#did=1"
    }
    print("YoukuAndroidMgr:testPay ------  3")
    self:startPay(payParam)
  end, 4)
end
return YoukuAndroidMgr
