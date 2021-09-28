require("channel.Interface.anysdkConst")
local AnysdkIOSMgr = class("AnysdkIOSMgr", ChannelClassBase)
local appKey = "27A5259A-D8E3-BA71-A2AB-1AEF349DA1A1"
local appSecret = "704c1907650bc019461aaa516edcb120"
local privateKey = "20F6CEC5C0E690A7EAD0D1377EA923A6"
local oauthLoginServer = "http://192.168.1.102:8003/anysdk/login?gameflag=xiyou"
local anysdkAgent = AgentManager:getInstance()
local anysdkUserPlugin, anysdkIAPMaps
local isDebugModel = false
function AnysdkIOSMgr:ctor()
  self.m_IsInitSucceed = false
  self.m_IsPaying = false
  self.m_UserInfo = {}
  self.m_IsCallLogin = false
  self.m_IsFirstLogin = true
end
function AnysdkIOSMgr:_callback(code, param)
  if self.m_Listener ~= nil then
    self.m_Listener(code, param)
  else
    print("--->> self.m_Listener = nil")
  end
end
function AnysdkIOSMgr:Init(gameParam, listener)
  self.m_Listener = listener
  anysdkAgent:init(appKey, appSecret, privateKey, oauthLoginServer)
  anysdkAgent:loadALLPlugin()
  anysdkUserPlugin = anysdkAgent:getUserPlugin()
  anysdkUserPlugin:setActionListener(handler(self, self.onActionListener))
  anysdkIAPMaps = anysdkAgent:getIAPPlugin() or {}
  print("==>> anysdk version:", anysdkAgent:getFrameworkVersion())
  print("==>> anysdk channelId:", self:getRealChannelId())
  for key, value in pairs(anysdkIAPMaps) do
    print("key:" .. key)
    print("value: " .. type(value))
    value:setResultListener(handler(self, self.onResult))
  end
  self.m_IsSwitchAccount = false
  local realChannelId = tostring(self:getRealChannelId())
  if realChannelId == "500017" or realChannelId == "500015" or realChannelId == "500035" then
    print("海马渠道不显示客服页面:")
    channel.showSettingFAQ = false
    channel.showUserCenterOnly = false
  end
  anysdkUserPlugin:setDebugMode(isDebugModel)
end
function AnysdkIOSMgr:getRealChannelId()
  if anysdkAgent then
    return anysdkAgent:getChannelId()
  end
end
function AnysdkIOSMgr:IsChannelId(realChannelId)
  return tostring(self:getRealChannelId()) == tostring(realChannelId)
end
function AnysdkIOSMgr:onActionListener(pPlugin, code, msg)
  print("111 -------->> AnysdkIOSMgr:onActionListener ")
  dump(UserActionResultCode, "UserActionResultCode")
  print("code:", code)
  print("msg:", type(msg), msg)
  dump(msg, "msg", 9)
  if code == UserActionResultCode.kInitSuccess then
    print("sdk初始化成功，游戏相关处理")
    self.m_IsInitSucceed = true
    self.m_IsCallLogin = false
    self:_callback(ChannelCallbackStatus.kInitSuccess)
  elseif code == UserActionResultCode.kInitFail then
    print("sdk初始化失败，游戏相关处理")
    self.m_IsInitSucceed = false
    self:_callback(ChannelCallbackStatus.kInitFail)
  end
  if code == UserActionResultCode.kLoginSuccess then
    print("登陆成功后，游戏相关处理:")
    if self:IsChannelId("500015") and self.m_IsCallLogin == false then
      self.m_UserInfo.token = msg
      self.m_UserInfo.uid = self:getAccount()
      self:_callback(ChannelCallbackStatus.kAccountSwitchSuccess)
    else
      self.m_UserInfo.token = msg
      self.m_IsCallLogin = false
      self.m_UserInfo.uid = self:getAccount()
      dump(self.m_UserInfo, "self.m_UserInfo", 9)
      self:_callback(ChannelCallbackStatus.kLoginSuccess)
    end
  elseif code == UserActionResultCode.kLoginTimeOut then
    self.m_IsCallLogin = false
    self:_callback(ChannelCallbackStatus.kLoginFail)
  elseif code == UserActionResultCode.kLoginCancel then
    self.m_IsCallLogin = false
    self:_callback(ChannelCallbackStatus.kLoginCancel)
  elseif code == UserActionResultCode.kLoginFail then
    self.m_IsCallLogin = false
    self:_callback(ChannelCallbackStatus.kLoginFail)
  elseif code == UserActionResultCode.kAccountSwitchSuccess then
    self.m_IsSwitchAccount = true
    self.m_UserInfo.token = msg
    self:_callback(ChannelCallbackStatus.kAccountSwitchSuccess)
  elseif code == UserActionResultCode.kAccountSwitchFail then
    self:_callback(ChannelCallbackStatus.kAccountSwitchFail)
  end
  if code == UserActionResultCode.kLogoutSuccess then
    self.m_IsSwitchAccount = false
    self:_callback(ChannelCallbackStatus.kLogoutSuccess)
  elseif code == UserActionResultCode.kLogoutFail then
    self:_callback(ChannelCallbackStatus.kLogoutFail)
  end
  if code == UserActionResultCode.kPlatformEnter then
  elseif code == UserActionResultCode.kPlatformBack and self.m_IsCallLogin and (self:IsChannelId("500004") or self:IsChannelId("500003")) then
    self.m_IsCallLogin = false
    self:_callback(ChannelCallbackStatus.kLoginFail)
  end
end
function AnysdkIOSMgr:isLogined()
  if anysdkUserPlugin then
    return anysdkUserPlugin:isLogined()
  end
end
function AnysdkIOSMgr:Login()
  if self:IsChannelId("500015") and self.m_IsSwitchAccount and self.m_UserInfo.token ~= nil then
    print("Login 切换帐号成功后重新登录处理:")
    self.m_UserInfo.uid = self:getAccount()
    if self.m_UserInfo.uid ~= nil then
      self.m_IsSwitchAccount = false
      self:_callback(ChannelCallbackStatus.kLoginSuccess)
      return
    end
  end
  if self:IsChannelId("500003") and self.m_IsFirstLogin ~= true then
    self:Logout()
  end
  print("AnysdkIOSMgr:Login--->>", anysdkUserPlugin)
  self.m_IsFirstLogin = false
  self.m_IsSwitchAccount = false
  if anysdkUserPlugin then
    print("2 AnysdkIOSMgr:Login--->>", anysdkUserPlugin)
    self.m_IsCallLogin = true
    return anysdkUserPlugin:login()
  end
end
function AnysdkIOSMgr:getAccount()
  if anysdkUserPlugin then
    return anysdkUserPlugin:getUserID()
  end
end
function AnysdkIOSMgr:sendLoginProtocol(gameType, deveceType)
  local ver = GetVersionStr()
  if not channel.needUpdate then
    ver = "999.999.999"
  end
  local vToken = self.m_UserInfo.token
  NetSend({
    s_gf = gameType,
    s_vtoken = vToken,
    i_dtp = deveceType,
    t_v = ver
  }, S2C_Account, "P12")
  return true
end
function AnysdkIOSMgr:Logout()
  local anysdkUserPlugin = anysdkAgent:getUserPlugin()
  if nil ~= anysdkUserPlugin and anysdkUserPlugin:isFunctionSupported("logout") then
    anysdkUserPlugin:callFuncWithParam("logout")
  end
end
function AnysdkIOSMgr:showToolBar(place)
  if anysdkUserPlugin and anysdkUserPlugin:isFunctionSupported("showToolBar") then
    local r_place = ToolBarPlace.kToolBarTopLeft
    if place == ChannelToolBarPlace.kToolBarTopLeft then
      r_place = ToolBarPlace.kToolBarTopLeft
    elseif place == ChannelToolBarPlace.kToolBarTopRight then
      r_place = ToolBarPlace.kToolBarTopRight
    elseif place == ChannelToolBarPlace.kToolBarMidLeft then
      r_place = ToolBarPlace.kToolBarMidLeft
    elseif place == ChannelToolBarPlace.kToolBarMidRight then
      r_place = ToolBarPlace.kToolBarMidRight
    elseif place == ChannelToolBarPlace.kToolBarBottomLeft then
      r_place = ToolBarPlace.kToolBarBottomLeft
    elseif place == ChannelToolBarPlace.kToolBarBottomRight then
      r_place = ToolBarPlace.kToolBarBottomRight
    end
    local param1 = PluginParam:create(ToolBarPlace.kToolBarTopLeft)
    anysdkUserPlugin:callFuncWithParam("showToolBar", {param1})
  end
end
function AnysdkIOSMgr:hideToolBar()
end
function AnysdkIOSMgr:enterPersonCenter()
  if nil ~= anysdkUserPlugin and anysdkUserPlugin:isFunctionSupported("enterPlatform") then
    anysdkUserPlugin:callFuncWithParam("enterPlatform")
  end
end
function AnysdkIOSMgr:startPay(payParam)
  if anysdkIAPMaps == nil then
    self:_callback(ChannelPayResult.kPayFailed)
    return false
  end
  local info = {
    Product_Price = checkint(payParam.amount),
    Product_Id = payParam.dataId,
    Product_Name = payParam.payDataName,
    Server_Id = payParam.serverId,
    Product_Count = "1",
    Role_Id = payParam.roleId,
    Role_Name = payParam.roleName,
    Role_Grade = payParam.roleLv,
    Role_Balance = payParam.hadGold,
    EXT = payParam.customInfo
  }
  if self:IsChannelId(500002) then
    info.Product_Name = ""
  end
  dump(info, "info")
  print("self.m_IsPaying:", self.m_IsPaying)
  if self.m_IsPaying == true then
    ProtocolIAP:resetPayState()
    self.m_IsPaying = false
  end
  for key, value in pairs(anysdkIAPMaps) do
    print("key:" .. key)
    print("value: " .. type(value))
    self.m_IsPaying = true
    value:payForProduct(info)
  end
  return true
end
function AnysdkIOSMgr:onResult(code, msg, info)
  print("--->> AnysdkIOSMgr:onResult:")
  print("code:", code)
  print("msg:", msg)
  dump(info, "info", 9)
  if code == PayResultCode.kPaySuccess then
    print("AnysdkIOSMgr IAP 充值成功")
    self:_callback(ChannelPayResult.kPaySucceed)
    self.m_IsPaying = false
  elseif code == PayResultCode.kPayCancel then
    print("AnysdkIOSMgr IAP 充值取消")
    self:_callback(ChannelPayResult.kPayViewClosed)
    self.m_IsPaying = false
  elseif code == PayResultCode.kPayInitFail or code == PayResultCode.kPayNetworkError or code == PayResultCode.kPayProductionInforIncomplete or code == PayResultCode.kPayFail or code == PayResultCode.kPayNowPaying then
    print("AnysdkIOSMgr IAP 充值 失败")
    self:_callback(ChannelPayResult.kPayFailed)
    self.m_IsPaying = false
  end
end
return AnysdkIOSMgr
