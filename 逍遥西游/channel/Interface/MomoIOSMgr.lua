local MomoIOSMgr = class("MomoIOSMgr", ChannelClassBase)
local momo_iap_products = {
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
  [12] = "com.mgame1.xycq.12",
  [13] = "com.mgame1.xycq.13",
  [14] = "com.mgame1.xycq.14",
  [15] = "com.mgame1.xycq.21"
}
local momo_iap_products_ids = {}
for k, v in pairs(momo_iap_products) do
  momo_iap_products_ids[#momo_iap_products_ids + 1] = v
end
function MomoIOSMgr:ctor()
  self.m_PlaceTranform = {
    [ChannelToolBarPlace.kToolBarTopLeft] = 0,
    [ChannelToolBarPlace.kToolBarTopRight] = 2,
    [ChannelToolBarPlace.kToolBarMidLeft] = 0,
    [ChannelToolBarPlace.kToolBarMidRight] = 0,
    [ChannelToolBarPlace.kToolBarBottomLeft] = 1,
    [ChannelToolBarPlace.kToolBarBottomRight] = 3
  }
  self.m_LoginInfo = {}
  self.m_Listener = nil
  self.m_ReqFriendListListener = nil
  self.m_ReqAddFriendListener = nil
  self.m_ReqShareToUserListener = nil
  self.m_IsLoginSucceedCallback = false
  self.m_ClassName = "MomoInter"
  self.m_UserInfo = nil
  luaoc.callStaticMethod(self.m_ClassName, "setMessageListener", {
    listener = handler(self, self.MessageCallBack)
  })
end
function MomoIOSMgr:_callback(code, param)
  if self.m_Listener ~= nil then
    self.m_Listener(code, param)
  else
    print("--->> self.m_Listener = nil")
  end
end
function MomoIOSMgr:MessageCallBack(data, isSucceed)
  if data == nil then
    printLog("ERROR", "回调参数出错")
    return
  end
  local typ = tonumber(data.type)
  local param = data.param
  print(string.format([[

-------------------------------------
 MomoMgr:MessageCallBack:%s,%s
]], tostring(typ), tostring(param)))
  if typ == 0 then
    self:_callback(ChannelCallbackStatus.kInitSuccess)
  elseif typ == -1 then
    self:_callback(ChannelCallbackStatus.kInitFail)
  elseif typ == 1 then
    self.m_IsLoginSucceedCallback = true
    self.m_LoginInfo.userId = param.user.userID
    self.m_LoginInfo.vtoken = param.token
    self.m_UserInfo = param.user
    print("------->>>userId:", self.m_LoginInfo.userId)
    print("------->>>vtoken:", self.m_LoginInfo.vtoken)
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
    scheduler.performWithDelayGlobal(function()
      self:reqAllProducts()
    end, 1)
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
    self:CallbackReqFriendListListener(false, param.errorCode, param.errorMsg)
  elseif typ == 14 then
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
    self:_callback(ChannelPayResult.kPaySucceed)
  elseif typ == 32 then
    print("MomoIOS IAP 充值失败")
    self:_callback(ChannelPayResult.kPayFailed)
  end
end
function MomoIOSMgr:Init(gameParam, listener)
  print("MomoIOSMgr:Init:", listener)
  self.m_Listener = listener
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "InitSDK")
  if ok ~= true then
    self:_callback(ChannelCallbackStatus.kInitFail)
  end
end
function MomoIOSMgr:isLogined()
  local result, token, userType, userName = self:getCacheAuthInfo()
  self.m_LoginInfo.userType = userType
  self.m_LoginInfo.userName = userName
  print("isLogined, result, token, userType, userName:", result, token, userType, userName)
  if result == true and token ~= nil then
    return true
  end
  return false
end
function MomoIOSMgr:getCacheAuthInfo()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "getAuthInfo")
  if ok and ret ~= nil then
    local r, t, ut, un = string.match(ret, "(.*),(.*),(.*),(.*)")
    return tonumber(r) == 1, t, tonumber(ut), un
  end
  return false
end
function MomoIOSMgr:Login()
  self.m_IsLoginSucceedCallback = false
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "loginMomo")
  if ret ~= "1" then
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function MomoIOSMgr:LoginFinished_(isCloseLoginView)
  if self.m_IsLoginSucceedCallback == true or self:isLogined() then
    self:_callback(ChannelCallbackStatus.kLoginSuccess)
  elseif isCloseLoginView == true then
    self:_callback(ChannelCallbackStatus.kLoginCancel)
  else
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function MomoIOSMgr:getUserInfo()
  return self.m_UserInfo
end
function MomoIOSMgr:getAccount()
  if self.m_LoginInfo then
    return self.m_LoginInfo.userId
  end
end
function MomoIOSMgr:Logout()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "logoutMomo")
  if ok and ret == "1" then
    return true
  else
    self:_callback(ChannelCallbackStatus.kLogoutFail)
    return false
  end
end
function MomoIOSMgr:sendLoginProtocol(gameType, deveceType)
  print("---->> MomoIOSMgr:sendLoginProtocol")
  local vToken = self.m_LoginInfo.vtoken
  if vToken == nil then
    print("----->> token == nil")
    return
  end
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  NetSend({
    s_gf = gameType,
    s_userid = self.m_LoginInfo.userId,
    s_vtoken = vToken,
    i_dtp = deveceType,
    t_v = ver
  }, S2C_Account, "P4")
  return true
end
function MomoIOSMgr:setGameServer(serverParam)
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "setGameServer", {
    server = serverParam.serverId
  })
  if ok and ret == "1" then
    return true
  else
    return false
  end
end
function MomoIOSMgr:showToolBar(place)
  do return end
  local showPlace = self.m_PlaceTranform[place]
  if showPlace == nil then
    showPlace = 0
  end
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "setShowMomoLogo", {show = 1, place = showPlace})
  if ok and ret == "1" then
    return true
  else
    return false
  end
end
function MomoIOSMgr:hideToolBar()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "setShowMomoLogo", {show = 0})
  if ok and ret == "1" then
    return true
  else
    return false
  end
end
function MomoIOSMgr:enterPersonCenter()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "showPersonalCenter")
  if ok and ret == "1" then
    return true
  else
    return false
  end
end
function MomoIOSMgr:startPay(payParam)
  local dataId = payParam.dataId
  local productId = momo_iap_products[dataId]
  if productId ~= nil then
    local cbid = payParam.cbid
    if cbid ~= nil then
      local ok, ret
      if channel.devicePlatformType == 3 then
        ok, ret = luaoc.callStaticMethod(self.m_ClassName, "startJailbreakTrade", {productId = productId, customInfo = cbid})
      else
        ok, ret = luaoc.callStaticMethod(self.m_ClassName, "startPay", {productId = productId, customInfo = cbid})
      end
      if ok and ret == "1" then
        return true
      end
    end
  end
  self:_callback(ChannelPayResult.kPayFailed)
  return false
end
function MomoIOSMgr:getDid()
  return 1
end
function MomoIOSMgr:reqAllProducts()
  local param = {}
  param.num = #momo_iap_products_ids
  for i, v in ipairs(momo_iap_products_ids) do
    param[tostring(i)] = v
  end
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "reqAllProducts", param)
  if ok and ret == "1" then
    return true
  else
    return false
  end
end
function MomoIOSMgr:showFAQView()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "showFAQView")
  if ok and ret == "1" then
    return true
  else
    return false
  end
end
function MomoIOSMgr:enterForumOrTieba()
  local ok, ret = luaoc.callStaticMethod(self.m_ClassName, "launchToTieba")
  if ok and ret == "1" then
    return true
  else
    return false
  end
end
function MomoIOSMgr:getFriendList(listener)
  self.m_ReqFriendListListener = listener
  local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "getFriendList")
  if ok and ret == "1" then
    return ret
  else
    self:CallbackReqFriendListListener(false)
    return false
  end
end
function MomoIOSMgr:CallbackReqFriendListListener(...)
  listener = self.m_ReqFriendListListener
  self.m_ReqFriendListListener = nil
  if listener then
    listener(...)
  end
end
function MomoIOSMgr:addFriend(userId, listener, extParam)
  self.m_ReqAddFriendListener = listener
  local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "addFriend", {
    userId = userId,
    reason = extParam.reason
  })
  if ok and ret == "1" then
    return ret
  else
    self:CallbackReqAddFriendListener(false)
    return false
  end
end
function MomoIOSMgr:CallbackReqAddFriendListener(...)
  listener = self.m_ReqAddFriendListener
  self.m_ReqAddFriendListener = nil
  if listener then
    listener(...)
  end
end
function MomoIOSMgr:shareToUser(userId, listener, contend, extParam)
  self.m_ReqShareToUserListener = listener
  local shareType = extParam.shareType
  if shareType == nil then
    shareType = 1
  end
  local ok, ret = luaoc.callStaticMethod(MomoInter.cls_ios, "shareToUser", {
    userId = userId,
    content = contend,
    shareType = shareType
  })
  if ok and ret == "1" then
    return ret
  else
    self:CallbackReqShareToUserListener(false)
    return false
  end
end
function MomoIOSMgr:CallbackReqShareToUserListener(...)
  listener = self.m_ReqShareToUserListener
  self.m_ReqShareToUserListener = nil
  if listener then
    listener(...)
  end
end
function MomoIOSMgr:Clean()
  self.m_Listener = nil
end
return MomoIOSMgr
