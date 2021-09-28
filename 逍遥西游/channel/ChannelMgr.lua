local ChannelMgr = class("ChannelMgr")
function ChannelMgr:ctor()
  self.m_IsInitFinished = false
  self.m_IsInitSucceed = false
  self.m_IsNeedLogin = false
  self.m_ReqOrderListener = nil
end
function ChannelMgr:Init(initFinishListener)
  MoMoDataCenterExtend.extended(self)
  self.m_InitFinishListener = initFinishListener
  if channel.interClassName ~= nil then
    if channel_is_reload_ins then
      self.m_channelInter = channel_is_reload_ins
      scheduler.performWithDelayGlobal(function()
        self:MsgCallback(ChannelCallbackStatus.kInitSuccess)
      end, 0.1)
    else
      self.m_channelInter = require("channel.Interface." .. channel.interClassName).new()
      self.m_channelInter:Init(channel.gameParam, handler(self, self.MsgCallback))
    end
  else
    self.m_IsInitFinished = true
  end
  self:InitFinishCallback()
end
function ChannelMgr:InitFinishCallback()
  print("-->> InitFinishCallback:", self.m_channelInter)
  if (self.m_channelInter == nil or self.m_IsInitFinished) and self.m_InitFinishListener then
    self.m_InitFinishListener()
    self.m_InitFinishListener = nil
  end
end
function ChannelMgr:MsgCallback(typ, param)
  print("ChannelMgr:MsgCallback:", typ)
  if typ == ChannelCallbackStatus.kInitSuccess then
    print("初始化 SDK 成功")
    self.m_IsInitFinished = true
    self.m_IsInitSucceed = true
    self:InitFinishCallback()
    self:detectLogin()
  elseif typ == ChannelCallbackStatus.kInitFail then
    print("初始化 SDK 失败")
    self.m_IsInitFinished = true
    self.m_IsInitSucceed = false
    self:InitFinishCallback()
    self:detectLogin()
    self.m_IsNeedLogin = false
  elseif typ == ChannelCallbackStatus.kLoginSuccess then
    print("登录 成功")
    SendMessage(MSGID_Channel_LoginSucceed)
    if channel.useTalkingData then
      g_TalkingDataMgr:onLogin(self:getAccount())
    end
  elseif typ == ChannelCallbackStatus.kLoginFail then
    print("登录失败")
    SendMessage(MSGID_Channel_LoginFailed)
  elseif typ == ChannelCallbackStatus.kLoginCancel then
    print("取消登录")
    SendMessage(MSGID_Channel_LoginCannel)
  elseif typ == ChannelCallbackStatus.kGuestRegistered then
    print("游客注册为正式帐号")
    SendMessage(MSGID_Channel_GuestRegistered)
  elseif typ == ChannelCallbackStatus.kAccountSwitchSuccess then
    print("切换帐号成功")
    g_DataMgr:returnToLoginView()
    SendMessage(MSGID_Channel_LoginSucceed)
  elseif typ == ChannelCallbackStatus.kAccountSwitchFail then
    print("切换帐号失败")
    g_NetConnectMgr:deleteLoadingLayer()
  elseif typ == ChannelCallbackStatus.kLogoutSuccess then
    print("登出 成功")
    SendMessage(MSGID_Channel_LogoutSucceed)
  elseif typ == ChannelCallbackStatus.kLogoutFail then
    print("登出 失败")
    g_NetConnectMgr:deleteLoadingLayer()
    SendMessage(MSGID_Channel_LogoutFailed)
  elseif typ == ChannelPayResult.kPaySucceed then
    print("充值 成功")
    SendMessage(MSGID_Channel_PaySucceed)
    g_NetConnectMgr:deleteLoadingLayer()
  elseif typ == ChannelPayResult.kPayViewCommit then
    print("充值 充值成功并提交了")
    g_NetConnectMgr:deleteLoadingLayer()
  elseif typ == ChannelPayResult.kPayFailed then
    print("充值 失败")
    SendMessage(MSGID_Channel_PayFailed)
    g_NetConnectMgr:deleteLoadingLayer()
  elseif typ == ChannelPayResult.kPayViewClosed then
    print("充值 关闭")
    SendMessage(MSGID_Channel_PayViewClosed)
    g_NetConnectMgr:deleteLoadingLayer()
  else
    g_NetConnectMgr:deleteLoadingLayer()
  end
end
function ChannelMgr:isLogined()
  if self.m_IsInitFinished == false then
    return false
  end
  if self.m_IsInitSucceed == false then
    return false
  end
  if self.m_channelInter == nil then
    self:printChannelInterNilError("isLogined")
    return
  end
  return self.m_channelInter:isLogined()
end
function ChannelMgr:Login()
  if self.m_channelInter == nil then
    self:printChannelInterNilError("Login")
    return false
  end
  self.m_IsNeedLogin = true
  self:detectLogin()
  return true
end
function ChannelMgr:detectLogin()
  print("detectLogin:self.m_IsInitFinished, self.m_IsNeedLogin=", self.m_IsInitFinished, self.m_IsNeedLogin)
  if self.m_IsInitFinished and self.m_IsNeedLogin then
    if self.m_IsInitSucceed then
      self.m_channelInter:Login()
    else
      self:Init()
    end
  end
end
function ChannelMgr:getAccount()
  if self.m_channelInter == nil then
    self:printChannelInterNilError("getAccount")
    return nil
  end
  return self.m_channelInter:getAccount()
end
function ChannelMgr:getUserInfo()
  if self.m_channelInter == nil then
    self:printChannelInterNilError("Login")
    return nil
  end
  return self.m_channelInter:getUserInfo()
end
function ChannelMgr:Logout()
  if self.m_channelInter == nil then
    self:printChannelInterNilError("Logout")
    return
  end
  self.m_channelInter:Logout()
end
function ChannelMgr:sendLoginProtocol(gameType, deveceType)
  if self.m_channelInter == nil then
    self:printChannelInterNilError("sendLoginProtocol")
    return
  end
  self.m_channelInter:sendLoginProtocol(gameType, deveceType)
end
function ChannelMgr:setGameServer(serverParam)
  if self.m_channelInter == nil then
    self:printChannelInterNilError("setGameServer")
    return
  end
  self.m_channelInter:setGameServer(serverParam)
end
function ChannelMgr:sendRoleInfoAfterLogin(roleParam)
  if self.m_channelInter == nil then
    self:printChannelInterNilError("sendRoleInfoAfterLogin")
    return
  end
  if self.m_channelInter.sendRoleInfoAfterLogin then
    self.m_channelInter:sendRoleInfoAfterLogin(roleParam)
  end
end
function ChannelMgr:RoleLevelUp(roleParam)
  if self.m_channelInter == nil then
    self:printChannelInterNilError("RoleLevelUp")
    return
  end
  if self.m_channelInter.RoleLevelUp then
    self.m_channelInter:RoleLevelUp(roleParam)
  end
end
function ChannelMgr:showToolBar(place)
  if self.m_channelInter == nil then
    self:printChannelInterNilError("showToolBar")
    return
  end
  self.m_channelInter:showToolBar(place)
end
function ChannelMgr:hideToolBar()
  if self.m_channelInter == nil then
    self:printChannelInterNilError("hideToolBar")
    return
  end
  self.m_channelInter:hideToolBar()
end
function ChannelMgr:enterPersonCenter()
  if self.m_channelInter == nil then
    self:printChannelInterNilError("enterPersonCenter")
    return
  end
  self.m_channelInter:enterPersonCenter()
end
function ChannelMgr:showFAQView()
  if self.m_channelInter == nil then
    self:printChannelInterNilError("showFAQView")
    return
  end
  self.m_channelInter:showFAQView()
end
function ChannelMgr:enterForumOrTieba()
  if self.m_channelInter == nil then
    self:printChannelInterNilError("enterForumOrTieba")
    return
  end
  self.m_channelInter:enterForumOrTieba()
end
function ChannelMgr:startPay(rmb, gId)
  if self.m_channelInter == nil then
    self:printChannelInterNilError("startPay")
  end
  g_NetConnectMgr:showLoadingLayer()
  local serverId, _, _, payId = g_DataMgr:getChoosedLoginServerInfo()
  local servername = g_DataMgr:getLoginServerName()
  local pid = g_LocalPlayer:getPlayerId()
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local roleName = g_LocalPlayer:getObjProperty(1, PROPERTY_NAME)
  local Mdate = data_Shop_ChongZhi[gId] or {}
  local mitemname = Mdate.name or "元宝"
  local mdefaultCount = Mdate.addGold or 1
  local checkName = Mdate.checkName
  local si, ei = string.find(checkName, "节日礼包")
  if si and si > 0 then
  else
    mitemname = string.gsub(mitemname, tostring(mdefaultCount), "")
  end
  local dfc = 1
  if mdefaultCount > 0 then
    dfc = mdefaultCount
  end
  local munitprice = Mdate.rmb / dfc
  local did
  if self.m_channelInter ~= nil then
    did = self.m_channelInter:getDid()
  else
    did = 2
  end
  local player = g_DataMgr:getPlayer()
  local vipLv = 1
  if player then
    vipLv = player:getVipLv()
  end
  local hadGold = g_LocalPlayer:getGold()
  local payParam = {
    dataId = gId,
    serverId = serverId,
    serverName = servername,
    roleId = pid,
    roleName = roleName,
    roleLv = lv,
    amount = rmb,
    customInfo = string.format("gf=%s#kid=%s#rid=%s#gid=%s#did=%d", GameType, payId, pid, gId, did),
    payDataName = Mdate.name or "元宝",
    itemName = mitemname,
    UnitPrice = munitprice,
    defaultCount = dfc,
    checkName = checkName,
    hadGold = hadGold,
    vipLv = vipLv
  }
  print("channel.needPayOrderidFromServer:", channel.needPayOrderidFromServer)
  if channel.needPayOrderidFromServer then
    g_ChannelMgr:startReqPayOrderId(payParam.customInfo, function(cbid)
      print("-------=== >> startReqPayOrderId callback:", cbid)
      if cbid == nil then
        self:MsgCallback(ChannelPayResult.kPayFailed)
      else
        payParam.cbid = cbid
        dump(payParam, "payParam")
        self.m_channelInter:startPay(payParam)
      end
    end)
  else
    dump(payParam, "payParam")
    if self.m_channelInter == nil then
      SyNative.jinzhuPay(payParam)
    else
      self.m_channelInter:startPay(payParam)
    end
  end
end
function ChannelMgr:startReqPayOrderId(cbinfo, listener)
  self.m_ReqOrderListener = listener
  netsend.login.reqPayOrderId(cbinfo)
end
function ChannelMgr:reqPayOrderIdResult(cbid, listener)
  print("[reqPayOrderId]reqPayOrderIdResult-->", cbid)
  local listener = self.m_ReqOrderListener
  self.m_ReqOrderListener = nil
  if cbid and listener then
    listener(cbid)
  end
end
function ChannelMgr:requestExitGame(listener)
  local function exitGameFun(result)
    if self.momoDCExit and result == 1 then
      self:momoDCExit()
    end
    if listener then
      listener(result)
    end
  end
  if self.m_channelInter == nil then
    self:printChannelInterNilError("requestExitGame")
    exitGameFun(1)
    return
  end
  self.m_channelInter:requestExitGame(exitGameFun)
end
function ChannelMgr:getFriendList(listener)
  if self.m_channelInter == nil then
    self:printChannelInterNilError("getFriendList")
    return
  end
  self.m_channelInter:getFriendList(listener)
end
function ChannelMgr:addFriend(userId, listener, extParam)
  extParam = extParam or {}
  if self.m_channelInter == nil then
    self:printChannelInterNilError("addFriend")
    return
  end
  self.m_channelInter:addFriend(userId, listener, extParam)
end
function ChannelMgr:shareToUser(userId, listener, contend, extParam)
  extParam = extParam or {}
  if self.m_channelInter == nil then
    self:printChannelInterNilError("addFriend")
    return
  end
  self.m_channelInter:shareToUser(userId, listener, contend, extParam)
end
function ChannelMgr:getRealChannelId()
  local no = channel.no
  if self.m_channelInter ~= nil then
    local _no = self.m_channelInter:getRealChannelId()
    if _no ~= nil then
      no = _no
    else
      print("getRealChannelId 返回nil,使用本地渠道号")
    end
  end
  return no
end
function ChannelMgr:CreateRoleSucceed(roleId, roleType, roleName)
  if channel.useTalkingData then
    g_TalkingDataMgr:onCreateRole(roleName)
  end
  if self.m_channelInter ~= nil and self.m_channelInter.createRole ~= nil then
    local serverId = g_DataMgr:getChoosedLoginServerInfo()
    local serverName = g_DataMgr:getLoginServerName() or "未知服务器"
    local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
    local bpid = g_BpMgr:getLocalBpName()
    if bpid == nil or bpid == 0 or bpid == "" then
      bpid = "无帮派"
    end
    local player = g_DataMgr:getPlayer()
    local vipLv = 1
    local mbalance = 0
    if player then
      vipLv = player:getVipLv()
      mbalance = player:getGold()
    end
    local data = {
      serverId = serverId,
      serverName = serverName,
      roleId = roleId,
      roleName = roleName,
      roleLv = lv,
      bpName = bpid,
      balance = mbalance,
      viplv = vipLv
    }
    self.m_channelInter:createRole(data)
  end
end
function ChannelMgr:enterGame()
  if self.m_channelInter ~= nil and self.m_channelInter.enterGame ~= nil then
    local serverId = g_DataMgr:getChoosedLoginServerInfo()
    local serverName = g_DataMgr:getLoginServerName() or "未知服务器"
    local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
    local bpid = g_BpMgr:getLocalBpName()
    if bpid == nil or bpid == 0 or bpid == "" then
      bpid = "无帮派"
    end
    local player = g_DataMgr:getPlayer()
    local vipLv = 1
    local mbalance = 0
    if player then
      vipLv = player:getVipLv()
      mbalance = player:getGold()
    end
    local roleId = player:getPlayerId()
    local roleName = player.m_RoleName
    local data = {
      serverId = serverId,
      serverName = serverName,
      roleId = roleId,
      roleName = roleName,
      roleLv = lv,
      bpName = bpid,
      balance = mbalance,
      viplv = vipLv
    }
    self.m_channelInter:enterGame(data)
  end
end
function ChannelMgr:channelPaySuccess(param)
  print("====>>>> ChannelMgr:channelPaySuccess ", param)
  if param then
    local sdkType = param.s_type
    local channel = param.s_chnl
    local orderId = param.s_order
    local tid = param.s_tid
    local payTb = data_Shop_ChongZhi[tid] or {}
    local mny = payTb.rmb or 0
    if self.momoDCPay then
      self:momoDCPay({
        channelLabel = channel,
        tradeNo = orderId,
        tradeFee = mny,
        propId = tid,
        sdkType = sdkType
      })
    end
  end
end
function ChannelMgr:getChannelLabel()
  if self.m_channelInter and self.m_channelInter.getChannelLabel then
    return self.m_channelInter:getChannelLabel()
  end
end
function ChannelMgr:printChannelInterNilError(funcName)
  printLog("ChannelMgr", "ChannelInter is nil, func be called:%s", tostring(funcName))
end
function ChannelMgr:Clean()
  if self.m_channelInter then
    self.m_channelInter:Clean()
  end
end
if g_ChannelMgr ~= nil then
  channel_is_reload_module = true
  if channel.interClassName == "AnysdkIOSMgr" then
    channel_is_reload_ins = g_ChannelMgr.m_channelInter
  end
end
g_ChannelMgr = ChannelMgr.new()
