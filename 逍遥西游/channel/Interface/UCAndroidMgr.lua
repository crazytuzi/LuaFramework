local UCAndroidMgr = class("UCAndroidMgr", ChannelClassBase)
UCAndroidMgr.cls_ios = "UCAndroidMgr"
UCAndroidMgr.cls_and = "com/nomoga/channel/UCInter"
function UCAndroidMgr:ctor()
  self.m_IsLoginSucceedCallback = false
  self.m_Listener = nil
  self.m_ExitGameListener = nil
  self.m_Sid = nil
  callStaticMethodJava(UCAndroidMgr.cls_and, "setMessageListener", {
    handler(self, self.MessageCallBack)
  })
end
function UCAndroidMgr:MessageCallBack(data, isSucceed)
  print("UCAndroidMgr:MessageCallBack:")
  dump(data, "data")
  local typ = data.type
  if typ == 1 then
    self:_callback(ChannelCallbackStatus.kInitSuccess)
  elseif typ == 2 then
    self:_callback(ChannelCallbackStatus.kInitFail)
  elseif typ == 11 then
    self.m_IsLoginSucceedCallback = true
  elseif typ == 12 then
    self:LoginFinished_(true)
  elseif typ == 13 then
  elseif typ == 31 then
    print("UC 退出帐号成功")
    self.m_Sid = nil
    self:_callback(ChannelCallbackStatus.kLogoutSuccess)
  elseif typ == 32 or typ == 33 or typ == 34 then
    self:_callback(ChannelCallbackStatus.kLogoutFail)
  elseif typ == 51 then
    print("UC 充值成功")
    self:_callback(ChannelPayResult.kPaySucceed)
  elseif typ == 52 then
    print("UC 充值失败, 没有初始化")
    self:_callback(ChannelPayResult.kPayFailed)
  elseif typ == 53 then
    print("UC 充值界面关闭")
    self:_callback(ChannelPayResult.kPayViewClosed)
  elseif typ == 61 then
    print("UC 退出游戏返回 继续游戏")
    self:callExitGame_(0)
  elseif typ == 62 then
    print("UC 退出游戏返回 退出游戏")
    self:callExitGame_(1)
  end
end
function UCAndroidMgr:Init(gameParam, listener)
  print("UCAndroidMgr:Init:", listener)
  self.m_Listener = listener
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "InitSDK", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kInitFail)
  end
end
function UCAndroidMgr:isLogined()
  return self:getSid() ~= nil
end
function UCAndroidMgr:Login()
  self.m_IsLoginSucceedCallback = false
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "Login", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function UCAndroidMgr:LoginFinished_(isCloseLoginView)
  self.m_Sid = self:getSid()
  print("-->UCAndroidMgr:LoginFinished_:", self.m_Sid)
  print("---->> 11111")
  if self.m_Sid == nil or self.m_IsLoginSucceedCallback ~= true then
    if isCloseLoginView == true then
      self:_callback(ChannelCallbackStatus.kLoginCancel)
    else
      self:_callback(ChannelCallbackStatus.kLoginFail)
    end
  else
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
  end
end
function UCAndroidMgr:getSid()
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "getSid", {}, "()Ljava/lang/String;")
  if ok == true then
    self.m_Sid = ret
    return ret
  end
end
function UCAndroidMgr:_callback(code, param)
  print("--->> _callback1:", self.m_Listener, code, param)
  if self.m_Listener ~= nil then
    print("--->> _callback2:", code, param)
    self.m_Listener(code, param)
  else
    print("--->> self.m_Listener = nil")
  end
end
function UCAndroidMgr:Logout()
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "Logout", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLogoutFail)
  end
end
function UCAndroidMgr:sendLoginProtocol(gameType, deveceType)
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  NetSend({
    s_gf = gameType,
    s_sid = self.m_Sid,
    i_dtp = deveceType,
    t_v = ver
  }, S2C_Account, "P5")
end
function UCAndroidMgr:setGameServer(serverParam)
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "setGameServer", {
    serverParam.serverName,
    serverParam.roleId,
    serverParam.roleName
  }, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function UCAndroidMgr:sendRoleInfoAfterLogin(roleParam)
  if roleParam.roleLv == nil or roleParam.roleLv <= 0 then
    roleParam.roleLv = 1
  end
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "sendRoleInfoAfterLogin", {
    roleParam.roleId,
    roleParam.roleName,
    tostring(roleParam.roleLv),
    getSubNumberFromString(roleParam.serverId),
    roleParam.serverName
  }, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function UCAndroidMgr:showToolBar(place)
  local x, y = getChannelTBPercentPosByPlace(place)
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "showToolBar", {x, y}, "(FF)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function UCAndroidMgr:hideToolBar()
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "hideToolBar", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function UCAndroidMgr:enterPersonCenter()
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "enterPersonCenter", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function UCAndroidMgr:getDid()
  return 2
end
function UCAndroidMgr:startPay(payParam)
  if payParam.roleLv == nil or payParam.roleLv <= 0 then
    payParam.roleLv = 1
  end
  local sendParam = {
    payParam.amount,
    payParam.customInfo,
    getSubNumberFromString(payParam.serverId),
    payParam.roleId,
    payParam.roleName,
    tostring(payParam.roleLv)
  }
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "startPay", sendParam, "(FLjava/lang/String;ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:_callback(ChannelPayResult.kPayFailed)
  return false
end
function UCAndroidMgr:requestExitGame(listener)
  self.m_ExitGameListener = listener
  local ok, ret = callStaticMethodJava(UCAndroidMgr.cls_and, "exitSDK", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:callExitGame_(1)
  return false
end
function UCAndroidMgr:callExitGame_(result)
  local listener = self.m_ExitGameListener
  self.m_ExitGameListener = nil
  if listener then
    listener(result)
  end
end
function UCAndroidMgr:getDid()
  return 2
end
function UCAndroidMgr:Clean()
  self.m_Listener = nil
  self.m_ExitGameListener = nil
end
return UCAndroidMgr
