local MiyuIosMgr = class("MiyuIosMgr", ChannelClassBase)
local appId = "116870"
local appKey = "645189e9d30f36146a7867b891286191c8951b10792f42b1"
local isDebugModel = 0
local gamePlatformType = 1
local payCallbackURLForDebug
function MiyuIosMgr:ctor()
  self.m_Listener = nil
  self.m_IsLoginSucceedCallback = false
  self.m_ClassName = "MYGameInter"
  self.m_LoginInfo = {}
  luaoc.callStaticMethod(self.m_ClassName, "setMessageListener", {
    listener = handler(self, self.MessageCallBack)
  })
end
function MiyuIosMgr:_callback(code, param)
  if self.m_Listener ~= nil then
    self.m_Listener(code, param)
  else
    print("--->> self.m_Listener = nil")
  end
end
function MiyuIosMgr:Init(gameParam, listener)
  print("MiyuIosMgr:Init:", listener)
  self.m_Listener = listener
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "InitSDK", {
    appId = appId,
    appKey = appKey,
    isDebugModel = isDebugModel,
    gamePlatformType = gamePlatformType
  })
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kInitFail)
  end
end
function MiyuIosMgr:isLogined()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "isLogin")
  if ok == false or ret ~= "1" then
    return false
  end
end
function MiyuIosMgr:Login()
  self.m_IsLoginSucceedCallback = false
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "login")
  if ok == false or ret ~= "1" then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function MiyuIosMgr:getUid()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "loginUid")
  if ok == false or ret == "0" then
    return nil
  end
  return ret
end
function MiyuIosMgr:getLoginAccessToken()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "loginAccessToken")
  if ok == false or ret == "0" then
    return nil
  end
  return ret
end
function MiyuIosMgr:Logout()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "logout")
  if ok and ret == "1" then
    return true
  else
    self:_callback(ChannelCallbackStatus.kLogoutFail)
    return false
  end
end
function MiyuIosMgr:setGameServer(serverParam)
end
function MiyuIosMgr:showToolBar(place)
  local r_place = 0
  if place == ChannelToolBarPlace.kToolBarTopLeft then
    r_place = 1
  elseif place == ChannelToolBarPlace.kToolBarTopRight then
    r_place = 2
  elseif place == ChannelToolBarPlace.kToolBarMidLeft then
    r_place = 3
  elseif place == ChannelToolBarPlace.kToolBarMidRight then
    r_place = 4
  elseif place == ChannelToolBarPlace.kToolBarBottomLeft then
    r_place = 5
  elseif place == ChannelToolBarPlace.kToolBarBottomRight then
    r_place = 6
  end
  return self:setToolBar(r_place)
end
function MiyuIosMgr:hideToolBar()
  return self:setToolBar(0)
end
function MiyuIosMgr:setToolBar(place)
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "showToolbar", {place = place})
  if ok == false or ret ~= "1" then
    return false
  end
  return true
end
function MiyuIosMgr:enterPersonCenter()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "showUserCenter")
  if ok == false or ret ~= "1" then
    return false
  end
  return true
end
function MiyuIosMgr:MessageCallBack(data, isSucceed)
  if data == nil then
    printLog("ERROR", "回调参数出错")
    return
  end
  local typ = tonumber(data.type)
  local param = data.param
  print(string.format([[

-------------------------------------
 MiyuIosMgr:MessageCallBack:%s,%s
]], tostring(typ), tostring(param)))
  if typ == 0 then
    self:_callback(ChannelCallbackStatus.kInitSuccess)
  elseif typ == -1 then
    self:_callback(ChannelCallbackStatus.kInitFail)
  elseif typ == 1 then
    self.m_IsLoginSucceedCallback = true
    self.m_LoginInfo.userId = self:getUid()
    self.m_LoginInfo.vtoken = self:getLoginAccessToken()
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
  elseif typ == 2 then
    if self.m_IsLoginSucceedCallback then
      self:_callback(ChannelCallbackStatus.kLogoutSuccess)
    else
      self.m_IsLoginSucceedCallback = false
      self:_callback(ChannelCallbackStatus.kLoginFail)
    end
  elseif typ == 5 then
    self.m_IsLoginSucceedCallback = false
    self:_callback(ChannelCallbackStatus.kGuestRegistered)
  elseif typ == 3 then
    print("baidu 退出帐号成功")
    self:_callback(ChannelCallbackStatus.kLogoutSuccess)
  elseif typ == 4 then
    self:_callback(ChannelCallbackStatus.kTokenInvild)
  elseif typ == 31 then
    print("MiyuIosMgr 充值成功")
    self:CallAfterPayDelay(ChannelPayResult.kPaySucceed)
  elseif typ == 32 then
    print("MiyuIosMgr 充值失败")
    self:CallAfterPayDelay(ChannelPayResult.kPayFailed)
  elseif typ == 33 then
    print("MiyuIosMgr 充值成功并提交了,")
    self:_callback(ChannelPayResult.kPayViewCommit)
  elseif typ == 34 then
    print("MiyuIosMgr 窗口关闭")
    self:_callback(ChannelPayResult.kPayViewClosed)
  end
end
function MiyuIosMgr:CallAfterPayDelay(cbkey)
  print("================>>>>>    MDAndMgr:CallAfterPayDelay  ")
  g_DataMgr.isPaying = false
  self:_callback(cbkey)
  scheduler.performWithDelayGlobal(function()
    print("  =================>>>>  delay  233333333333333  ")
    soundManager.OnEnterForeroundFlush()
    soundManager.setIsPlayingVideo(false)
    soundManager.resumeSoundTemp()
  end, 2)
end
function MiyuIosMgr:getUid()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "loginUid")
  if ok == false or ret == "0" then
    return nil
  end
  return ret
end
function MiyuIosMgr:getLoginAccessToken()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "loginAccessToken")
  if ok == false or ret == "0" then
    return nil
  end
  return ret
end
function MiyuIosMgr:sendLoginProtocol(gameType, deveceType)
  print("---->> MomoIOSMgr:sendLoginProtocol")
  local vToken = self.m_LoginInfo.vtoken
  local userId = self.m_LoginInfo.userId
  if vToken == nil or userId == nil then
    print("----->> vToken == nil or userId == nil ")
    print("vToken = ", vToken)
    print("userId = ", userId)
    self:_callback(ChannelCallbackStatus.kLoginFail)
    return false
  end
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  NetSend({
    s_gf = gameType,
    s_userid = userId,
    s_account = userId,
    s_vtoken = vToken,
    s_logintime = os.time(),
    i_dtp = deveceType,
    t_v = ver,
    m_mk = "MiyuIosMgr"
  }, S2C_Account, "P21")
  return true
end
function ChannelClassBase:startPay(payParam)
  local getsid = string.gmatch(payParam.serverId, "%d+")
  local mserverId = getsid()
  local payData = {
    orderId = payParam.cbid,
    name = payParam.payDataName,
    money = payParam.amount,
    productId = tostring(payParam.dataId),
    roleId = payParam.roleId,
    roleName = payParam.roleName,
    roleLv = payParam.roleLv,
    serverId = mserverId,
    serverName = payParam.serverName,
    extInfo = payParam.customInfo
  }
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "startPay", payData)
  if ok and ret == "1" then
    return true
  else
    self:_callback(ChannelPayResult.kPayFailed)
    return false
  end
end
function MiyuIosMgr:enterGame(roleParam)
  if roleParam == nil then
    roleParam = {}
  end
  if roleParam.serverId == nil then
    roleParam.serverId = "1"
  end
  local getsid = string.gmatch(roleParam.serverId, "%d+")
  local mserverId = getsid()
  print("yj call setRoleData ", roleParam.roleId, roleParam.roleName, roleParam.roleLv, roleParam.serverId, roleParam.serverName, roleParam.viplv)
  local roleData = {
    roleId = roleParam.roleId,
    roleName = roleParam.roleName,
    roleLevel = roleParam.roleLv,
    zoneId = mserverId,
    zoneName = roleParam.serverName,
    viplv = roleParam.viplv
  }
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "setRoleData", roleData)
  if ok and ret == "1" then
    return true
  else
    self:_callback(ChannelPayResult.kPayFailed)
    return false
  end
end
return MiyuIosMgr
