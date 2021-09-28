DashiAndMgr = class("DashiAndMgr", ChannelClassBase)
DashiAndMgr.cls_and = "com/md/channel/DashiInter"
DashiAndMgr.appID = "ex_xycq_bXwEMhv"
local md_iap_products = {
  [1] = "com.mgame1.xycq.1",
  [2] = "com.mgame1.xycq.2",
  [3] = "com.mgame1.xycq.3",
  [4] = "com.mgame1.xycq.4",
  [5] = "com.mgame1.xycq.5",
  [6] = "com.mgame1.xycq.6",
  [7] = "com.mgame1.xycq.7",
  [8] = "com.mgame1.xycq.8",
  [9] = "com.mgame1.xycq.9",
  [10] = "com.mgame1.xycq.10",
  [11] = "com.mgame1.xycq.11",
  [112] = "com.mgame1.xycq.15",
  [113] = "com.mgame1.xycq.16",
  [114] = "com.mgame1.xycq.17",
  [115] = "com.mgame1.xycq.18",
  [116] = "com.mgame1.xycq.19",
  [117] = "com.mgame1.xycq.20",
  [12] = "com.mgame1.xycq.12",
  [13] = "com.mgame1.xycq.13",
  [14] = "com.mgame1.xycq.14",
  [15] = "com.mgame1.xycq.21"
}
function DashiAndMgr:ctor()
  print(" 正在初始化      DashiAndMgr       ")
  self.m_LoginInfo = {}
  self.m_Listener = nil
  self.m_ReqFriendListListener = nil
  self.m_ReqAddFriendListener = nil
  self.m_ReqShareToUserListener = nil
  self.m_IsLoginSucceedCallback = false
  g_DataMgr.isPaying = false
  self.m_UserInfo = nil
  callStaticMethodJava(DashiAndMgr.cls_and, "setMessageListener", {
    handler(self, self.MessageCallBack)
  })
end
function DashiAndMgr:_callback(code, param)
  if self.m_Listener ~= nil then
    self.m_Listener(code, param)
  else
    print("--->> self.m_Listener = nil")
  end
end
function DashiAndMgr:MessageCallBack(data, isSucceed)
  if data == nil then
    printLog("ERROR", "回调参数出错")
    return
  end
  local typ = tonumber(data.type)
  local param = data.param
  print(string.format([[

-------------------------------------
 DashiAndMgr:MessageCallBack:%s,%s
]], tostring(typ), tostring(param)))
  if typ == 0 then
    self:_callback(ChannelCallbackStatus.kInitSuccess)
  elseif typ == -1 then
    self:_callback(ChannelCallbackStatus.kInitFail)
  elseif typ == 1 then
    self.m_IsLoginSucceedCallback = true
    self.m_LoginInfo.userName = param.user
    self.m_LoginInfo.account = param.user
    self.m_LoginInfo.sign = param.sign
    self.m_LoginInfo.loginTime = param.logintime
    self.m_UserInfo = param.user
    print("------->>>userName:", self.m_LoginInfo.userName)
    print("------->>>sign:", self.m_LoginInfo.sign)
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
  elseif typ == 10 then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  elseif typ == 2 then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  elseif typ == 4 then
    self:_callback(ChannelCallbackStatus.kTokenInvild)
  elseif typ == 3 then
    print("Momo 退出帐号成功")
    self:_callback(ChannelCallbackStatus.kLogoutSuccess)
  elseif typ == 13 then
    print(" 获取好友列表失败 ")
    self:CallbackReqFriendListListener(false, param.errorCode, param.errorMsg)
  elseif typ == 14 then
    print(" 获取好友列表成功 ")
    for k, v in pairs(param) do
      print(k, v)
    end
    self:CallbackReqFriendListListener(true, param)
  elseif typ == 21 then
    self:CallbackReqAddFriendListener(true)
  elseif typ == 22 then
    self:CallbackReqAddFriendListener(false, param.errorCode, param.errorMsg)
  elseif typ == 25 then
    self:CallbackReqShareToUserListener(true)
  elseif typ == 26 then
    self:CallbackReqShareToUserListener(false, param.errorCode, param.errorMsg)
  elseif typ == 31 then
    print("MomoIOS IAP 充值成功")
    self:CallAfterPayDelay(ChannelPayResult.kPaySucceed)
  elseif typ == 32 then
    print("MomoIOS IAP 充值失败")
    self:CallAfterPayDelay(ChannelPayResult.kPayFailed)
  elseif typ == 33 then
    self:CallAfterPayDelay(ChannelPayResult.kPayViewClosed)
  elseif typ == 61 then
    self:callExitGame_(0)
  elseif typ == 62 then
    self:callExitGame_(1)
  end
end
function DashiAndMgr:CallAfterPayDelay(cbkey)
  print("================>>>>>    DashiAndMgr:CallAfterPayDelay  ")
  g_DataMgr.isPaying = false
  self:_callback(cbkey)
  scheduler.performWithDelayGlobal(function()
    print("  =================>>>>  delay  233333333333333  ")
    soundManager.OnEnterForeroundFlush()
    soundManager.setIsPlayingVideo(false)
    soundManager.resumeSoundTemp()
  end, 2)
end
function DashiAndMgr:Init(gameParam, listener)
  print("   ********* getDeviceName = ", "--|" .. SyNative.getDeviceName() .. "|--")
  print("DashiAndMgr:Init:", listener)
  self.m_Listener = listener
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "InitSDK", {
    DashiAndMgr.appID
  }, "(Ljava/lang/String;)Ljava/lang/String;")
  print(" **********************  ok, ret  ", ok, ret)
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kInitFail)
  end
end
function DashiAndMgr:isLogined()
  local result, token, userType, userName = self:getCacheAuthInfo()
  print("DashiAndMgr:isLogined   ========>>> ", result, token, userType, userName)
  self.m_LoginInfo.userType = userType
  self.m_LoginInfo.userName = userName
  if result == true and token ~= nil then
    return true
  end
  return false
end
function DashiAndMgr:momoPushInit()
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "momoPushInit", {}, "()Ljava/lang/String;")
  if ok ~= true and ret == "1" then
    return true
  end
  return false
end
function DashiAndMgr:getCacheAuthInfo()
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "getAuthInfo", {}, "()Ljava/lang/String;")
  if ok and ret ~= nil and ret.token ~= nil then
    return true, ret.token, ret.userType, ret.userName
  end
  return false
end
function DashiAndMgr:Login()
  self.m_IsLoginSucceedCallback = false
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "Login", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function DashiAndMgr:LoginFinished_(isCloseLoginView)
  if self.m_IsLoginSucceedCallback == true or self:isLogined() then
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
  elseif isCloseLoginView == true then
    self:_callback(ChannelCallbackStatus.kLoginCancel)
  else
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function DashiAndMgr:getAccount()
  return self.m_LoginInfo.userid
end
function DashiAndMgr:getUserInfo()
  if self.m_LoginInfo then
    return self.m_UserInfo
  end
end
function DashiAndMgr:setGameServer(serverParam)
  if serverParam == nil then
    serverParam = {}
  end
  local mserverId = serverParam.serverId or "0"
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "setGameServer", {mserverId}, "(Ljava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function DashiAndMgr:Logout()
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "Logout", {}, "()Ljava/lang/String;")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kLogoutFail)
  end
end
function DashiAndMgr:sendLoginProtocol(gameType, deveceType)
  print("---->> DashiAndMgr:sendLoginProtocol")
  local vToken = self.m_LoginInfo.sign
  if vToken == nil then
    print("----->> token == nil")
    return
  end
  local market = SyNative.getAppChannelInfo("market", "A")
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  NetSend({
    s_gf = gameType,
    s_userid = self.m_LoginInfo.userid,
    s_account = self.m_LoginInfo.account,
    s_vtoken = vToken,
    s_logintime = self.m_LoginInfo.loginTime,
    i_dtp = deveceType,
    t_v = ver,
    m_mk = market
  }, S2C_Account, "P20")
  return true
end
function DashiAndMgr:showToolBar(place)
  do return end
  if place == nil or type(place) ~= "number" or place >= 4 or place < 0 then
    place = 0
  end
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "setShowMomoLogo", {1, place}, "(II)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function DashiAndMgr:hideToolBar()
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "setShowMomoLogo", {0, 1}, "(II)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function DashiAndMgr:enterPersonCenter()
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "showPersonalCenter", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function DashiAndMgr:startPay(payParam)
  if payParam == nil then
    self:_callback(ChannelPayResult.kPayFailed)
    return
  end
  local sendParam = {
    payParam.roleId,
    payParam.amount,
    payParam.serverId,
    payParam.payDataName,
    "商品描述",
    payParam.customInfo
  }
  dump(sendParam, "startpay sendParam")
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "startPay", sendParam, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:_callback(ChannelPayResult.kPayFailed)
  return false
end
function DashiAndMgr:getDid()
  return 2
end
function DashiAndMgr:Clean()
  g_DataMgr.isPaying = false
  self:__printInterNotImplement("Clean")
end
function DashiAndMgr:requestExitGame(listener)
  self.m_ExitGameListener = listener
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "requestExitGame", {}, "()V")
  if ok == true then
    return true
  end
  return false
end
function DashiAndMgr:callExitGame_(result)
  local listener = self.m_ExitGameListener
  self.m_ExitGameListener = nil
  if listener then
    listener(result)
  end
end
function DashiAndMgr:showFAQView()
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "questionCommint", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function DashiAndMgr:enterForumOrTieba()
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "launchToTieba", {}, "()Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  return false
end
function DashiAndMgr:getFriendList(listener)
  self.m_ReqFriendListListener = listener
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "getFriendList", {0}, "(I)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:CallbackReqFriendListListener(false)
  return false
end
function DashiAndMgr:CallbackReqFriendListListener(...)
  listener = self.m_ReqFriendListListener
  print("获取陌陌好友成功返回   5555555  *******************  ", listener == nil)
  print(...)
  self.m_ReqFriendListListener = nil
  if listener then
    listener(...)
  end
end
function DashiAndMgr:addFriend(userId, listener, extParam)
  listener = self.m_ReqAddFriendListener
  local reson = extParam.reason or "邀请你一起玩转《缘定星辰》！"
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "addFriend", {userId, reson}, "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:CallbackReqAddFriendListener(false)
  return false
end
function DashiAndMgr:CallbackReqAddFriendListener(...)
  listener = self.m_ReqAddFriendListener
  self.m_ReqAddFriendListener = nil
  if listener then
    listener(...)
  end
end
function DashiAndMgr:shareToUser(userId, listener, contend, extParam)
  self.m_ReqShareToUserListener = listener
  local shareType = extParam.shareType
  if shareType == nil then
    shareType = 1
  end
  local ok, ret = callStaticMethodJava(DashiAndMgr.cls_and, "shareToUser", {
    userId,
    contend,
    shareType
  }, "(Ljava/lang/String;Ljava/lang/String;I)Ljava/lang/String;")
  if ok == true and ret == "1" then
    return true
  end
  self:CallbackReqShareToUserListener(false)
  return false
end
function DashiAndMgr:CallbackReqShareToUserListener(...)
  listener = self.m_ReqShareToUserListener
  self.m_ReqShareToUserListener = nil
  if listener then
    listener(...)
  end
end
return DashiAndMgr
