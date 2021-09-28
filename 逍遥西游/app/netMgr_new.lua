local Define_HeartBeatCD = 5
local Define_PingSvrFailedTime = 5
local Define_LoginTimeOut = 5
local ConnectType_None = 0
local ConnectType_Login = 1
local ConnectType_Register = 2
local ConnectType_CreateRole = 3
local ConnectServerType_None = 0
local ConnectServerType_DataServer = 1
local ConnectServerType_GameServer = 2
DataServers = {
  {}
}
if g_IsRelease and _Config_Force_Use_LocalSvr ~= true then
  DataServers = {}
end
local dataServerFile = device.writablePath .. "xycq_data_server.txt"
print("dataServerFile:", dataServerFile)
local file = io.open(dataServerFile, "rb")
print("file:", file)
if file then
  local dataStr = file:read("*a")
  io.close(file)
  local f = loadstring(dataStr)
  if f and type(f) == "function" then
    DataServers = f()
    dump(DataServers, "DataServers")
  end
end
local CNetConnectMgr = class("CNetConnectMgr", nil)
function CNetConnectMgr:ctor()
  self.m_LastServerId = ""
  self.m_LoginResultListener = nil
  self.m_ConnectDataServerListener = nil
  self.m_IsCanSendProtocol = false
  self.m_ConnectSucceedFunc = {}
  self.m_TcpStatus = nil
  self.m_ConnectType = ConnectType_None
  print("self.m_IsConnectGameServer = false ----1")
  self.m_IsConnectGameServer = false
  self.m_IsConnectDataServer = false
  self.m_IsAutoReConnectAllServer = false
  self.m_CurConnectServerType = ConnectServerType_None
  self.m_AutoReconectTimes = 0
  self.m_IsBackground = false
  self.m_IsDealingWithReconnect = false
  self.m_SendHeartBeatFlagDict = {}
  self.m_ResultDlg = nil
  self.m_ReplacedDlg = nil
  self.m_IsLoginOut = false
  self.m_HbScheduler = scheduler.scheduleGlobal(handler(self, self.sendHeartBeat), Define_HeartBeatCD)
  self.m_PingSvrScheduler = nil
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Device)
  self:ListenMessage(MsgID_Connect)
end
function CNetConnectMgr:isNetWorkAvailable()
  return network.isLocalWiFiAvailable() or network.isInternetConnectionAvailable()
end
function CNetConnectMgr:resetProtocolEncrypt()
  self.m_IsCanSendProtocol = false
  self.m_ConnectSucceedFunc = {}
end
function CNetConnectMgr:addProtocoEncryptFinishListener(listener)
  print("CNetConnectMgr:addProtocoEncryptFinishListener:", listener, self.m_IsCanSendProtocol)
  if self.m_IsCanSendProtocol then
    print("CNetConnectMgr:addProtocoEncryptFinishListener-1:", listener)
    if listener then
      listener()
    end
  else
    print("CNetConnectMgr:addProtocoEncryptFinishListener-2:", #self.m_ConnectSucceedFunc)
    self.m_ConnectSucceedFunc[#self.m_ConnectSucceedFunc + 1] = listener
  end
end
function CNetConnectMgr:canSendProtocol()
  return self.m_IsCanSendProtocol == true
end
function CNetConnectMgr:ProtocolEncryptFinish()
  self.m_IsCanSendProtocol = true
  if self.m_ConnectSucceedFunc then
    for k, v in pairs(self.m_ConnectSucceedFunc) do
      v(true)
    end
  end
end
function CNetConnectMgr:CloseConnect()
  netconn:close()
  self.m_TcpStatus = NMGNET_STATUS_LOST
  print("self.m_IsConnectGameServer = false ----2")
  self:ResetConnectFlag()
  print("服务器连接断开  ********************  ")
end
function CNetConnectMgr:ResetConnectFlag()
  g_DataMgr:setIsSendFinished(false)
  self.m_IsConnectGameServer = false
  self.m_IsConnectDataServer = false
  self.m_IsAutoReConnectAllServer = false
  self.m_IsEnter = false
end
function CNetConnectMgr:IsConnectGameServer()
  return self.m_IsConnectGameServer
end
function CNetConnectMgr:ConnectDataServer(listener)
  self.m_ConnectDataServerListener = listener
  self.m_CurConnectDataServerIdx = 0
  self.m_IsConnectDataServer = false
  self:ConnectDataServer_()
end
function CNetConnectMgr:TryConnectDataServer(listener)
  if self.m_IsConnectDataServer then
    if listener then
      listener(true)
    end
  else
    self:ConnectDataServer(function()
      if listener then
        listener()
      end
    end)
  end
end
function CNetConnectMgr:ConnectDataServer_()
  print("---->>>ConnectDataServer_")
  self.m_CurConnectDataServerIdx = self.m_CurConnectDataServerIdx + 1
  self.m_CurConnectServerType = ConnectServerType_DataServer
  if self.m_CurConnectDataServerIdx > #DataServers then
    self.m_IsConnectDataServer = false
    self:ConnDataServerResult(MsgID_DataServer_ConnFailed)
  else
    g_DataMgr:setIsSendFinished(false)
    self:deleteResultDlg()
    self:resetProtocolEncrypt()
    local netInfo = DataServers[self.m_CurConnectDataServerIdx]
    local ip = netInfo[1]
    local port = netInfo[2]
    print("ConnectDataServer_--:", ip, port, tostring(self.m_CurConnectDataServerIdx))
    g_NetConnectMgr:CloseConnect()
    netconn:connect(function(status)
      print("CNetConnectMgr:ConnectDataServer_:", status)
      if status == NMGNET_STATUS_SUCCEED then
        self.m_IsConnectDataServer = true
        self:addProtocoEncryptFinishListener(function()
          self:ConnDataServerResult(MsgID_DataServer_ConnSucceed)
        end)
      elseif status == NMGNET_STATUS_LOST then
        self.m_IsConnectDataServer = false
        self:ConnDataServerResult(MsgID_DataServer_ConnLost)
      elseif status == NMGNET_STATUS_FAILED then
        self:ConnectDataServer_()
      end
    end, ip, port)
  end
end
function CNetConnectMgr:ConnDataServerResult(status)
  self.m_IsEnter = false
  print("self.m_ConnectDataServerListener:", status)
  if status == MsgID_DataServer_ConnSucceed then
    self:deleteResultDlg()
    self:deleteLoadingLayer()
    if type(self.m_ConnectDataServerListener) == "function" then
      self.m_ConnectDataServerListener()
    else
    end
  else
    self:networkIsNotAvailable(true, function()
      self:showLoadingLayer()
      self:ConnectDataServer(self.m_ConnectDataServerListener)
    end)
  end
  SendMessage(status)
end
function CNetConnectMgr:ConnectSvr(listener)
  self.m_ConnectType = ConnectType_None
  print("---->>>ConnectSvr")
  self:_ConnectSvr(listener)
end
function CNetConnectMgr:ConnectServerAndLogin(listener)
  print("---->>>ConnectServerAndLogin")
  self.m_ConnectType = ConnectType_Login
  self.m_LoginResultListener = listener
  self:_ConnectSvr(handler(self, self._login))
end
function CNetConnectMgr:LoginToGameServer(listener)
  self.m_ConnectType = ConnectType_Login
  self.m_LoginResultListener = listener
  self:_login(true)
end
function CNetConnectMgr:_login(isSucceed)
  self:showLoadingLayer()
  if isSucceed then
    if self.m_IsDealingWithReconnect then
      self:resetLogicData()
    end
    self:deleteResultDlg()
    if self.m_IsEnter ~= true then
      self.m_IsEnter = true
      local token, tcb = g_DataMgr:getDataServerTokenAndCb()
      netsend.login.reqEnter(token, tcb)
    end
  else
    self:callLoginResultListener(false)
  end
end
function CNetConnectMgr:loginTimeOut()
end
function CNetConnectMgr:startLoginTimeOutScheduler()
end
function CNetConnectMgr:stopLoginTimeOutScheduler()
end
function CNetConnectMgr:loginResult(resultType, msg, title)
  print("resultType  ======>>>> resultType = ", resultType)
  local isLoginSucceed = resultType == 1
  if isLoginSucceed then
    self.m_IsEnter = true
  else
    self.m_IsEnter = false
  end
  self:callLoginResultListener(isLoginSucceed)
  if isLoginSucceed then
    gamereset.resetAllForReconnect()
    if self.m_IsDealingWithReconnect then
      self:resetConnectData()
    end
  end
  g_DataMgr:loginGameServerResult(isLoginSucceed)
  SendMessage(MsgID_LoginWithTokenResult, isLoginSucceed)
  if resultType == 4 then
    self:deleteResultDlg()
    self:deleteLoadingLayer()
    local dlg = CPopWarning.new({
      title = title or "客户端版本过低",
      text = msg or "当前客户端版本过低，需要更新后才能进入游戏！",
      confirmFunc = handler(self, self.JumpToGameUpdate),
      confirmText = "确定",
      clearFunc = handler(self, self.onReplaceDlgClosed)
    })
    dlg:ShowCloseBtn(false)
    dlg:OnlyShowConfirmBtn()
    self:CloseConnect()
    self:resetConnectData(true)
    self.m_ReplacedDlg = dlg
    return
  elseif resultType == 5 then
    self:deleteResultDlg()
    self:deleteLoadingLayer()
    local dlg = CPopWarning.new({
      title = title or "登录提示",
      text = msg or "服务器正在维护中，请稍候登录游戏。",
      confirmFunc = function()
        g_DataMgr:returnToLoginView()
      end,
      confirmText = "确定",
      clearFunc = handler(self, self.onReplaceDlgClosed)
    })
    dlg:ShowCloseBtn(false)
    dlg:OnlyShowConfirmBtn()
    self:resetConnectData(true)
    self.m_ReplacedDlg = dlg
  elseif resultType == 6 then
    self:deleteResultDlg()
    self:deleteLoadingLayer()
    local dlg = CPopWarning.new({
      title = title,
      text = msg,
      confirmFunc = function()
        g_DataMgr:returnToLoginView()
      end,
      confirmText = "确定",
      clearFunc = handler(self, self.onReplaceDlgClosed),
      align = CRichText_AlignType_Left
    })
    dlg:ShowCloseBtn(false)
    dlg:OnlyShowConfirmBtn()
    self:resetConnectData(true)
    self.m_ReplacedDlg = dlg
  elseif not isLoginSucceed then
    self:tokenError()
  end
end
function CNetConnectMgr:JumpToGameUpdate()
  g_DataMgr:resetAllData()
  g_gameUpdate:CheckUpdate()
end
function CNetConnectMgr:callLoginResultListener(isSucceed)
  local listener = self.m_LoginResultListener
  self.m_LoginResultListener = nil
  if listener then
    listener(isSucceed)
  end
end
function CNetConnectMgr:_ConnectSvr(listener)
  local curServerId, ip, port = g_DataMgr:getChoosedLoginServerInfo()
  print("--->>_ConnectSvr:", curServerId, ip, port)
  if curServerId == nil or ip == nil or port == nil then
    return
  end
  self.m_IsLoginOut = false
  if not self:isNetWorkAvailable() then
    print("---->> _ConnectSvr: not self:isNetWorkAvailable")
    g_NetConnectMgr:CloseConnect()
    self:deleteLoadingLayer()
    self:networkIsNotAvailable()
    return
  end
  if self.m_TcpStatus == NMGNET_STATUS_SUCCEED and self.m_CurConnectServerType == ConnectServerType_GameServer then
    print("---->>> _ConnectSvr", self.m_LastServerId, curServerId)
    if self.m_LastServerId == curServerId then
      print("---->>> _ConnectSvr self.m_LastServerId == curServerId")
      self:_onConnectSvr(NMGNET_STATUS_SUCCEED, curServerId, listener)
      return
    else
      print("---->>> _ConnectSvr CloseConnect")
      g_NetConnectMgr:CloseConnect()
    end
  end
  g_DataMgr:setIsSendFinished(false)
  self:deleteResultDlg()
  self.m_TcpStatus = nil
  self.m_CurConnectServerType = ConnectServerType_GameServer
  print("CNetConnectMgr:开始连接服务器:", curServerId, ip, port)
  self:resetProtocolEncrypt()
  self:showLoadingLayer()
  self.m_IsEnter = false
  print("self.m_IsConnectGameServer = false ----3")
  self.m_IsConnectGameServer = false
  self.m_IsConnectDataServer = false
  netconn:connect(function(status)
    print("CNetConnectMgr:netconn connect status:", status, curServerId, listener)
    self:_onConnectSvr(status, curServerId, listener)
  end, ip, port)
end
function CNetConnectMgr:_onConnectSvr(status, curServerId, listener)
  print("CNetConnectMgr:_onConnectSvr:", status, curServerId, listener)
  if status == NMGNET_STATUS_SUCCEED then
    print("CNetConnectMgr:_onConnectSvr:-1")
    self:addProtocoEncryptFinishListener(function()
      print("CNetConnectMgr: self.addProtocoEncryptFinishListener")
      self:deleteLoadingLayer()
      self.m_IsConnectGameServer = true
      self.m_LastServerId = curServerId
      if listener then
        listener(true)
      end
      SendMessage(MsgID_GameServer_ConnSucceed)
    end)
  elseif status == NMGNET_STATUS_LOST then
    print("CNetConnectMgr:_onConnectSvr:-2")
    self:deleteLoadingLayer()
    if listener then
      listener(false)
    end
    SendMessage(MsgID_GameServer_ConnLost)
  elseif status == NMGNET_STATUS_FAILED then
    print("CNetConnectMgr:_onConnectSvr:-3")
    self:deleteLoadingLayer()
    if listener then
      listener(false)
    end
    SendMessage(MsgID_GameServer_ConnFailed)
  end
  self:onTcpStatusChanged(status)
end
function CNetConnectMgr:setConnectServerId(serverId)
  self.m_LastServerId = serverId
end
function CNetConnectMgr:ConnectSvrAndCreatRole(roleType, name, heroindex, rdTimes, edFlag)
  self.m_ConnectType = ConnectType_CreateRole
  self.m_CreateRoleType = roleType
  self.m_CreateRoleName = name
  self.m_CreateRoleHeroIdx = heroindex
  self.m_CreateRoleRandomTimes = rdTimes
  self.m_CreateRoleEditFlag = edFlag
  self:showLoadingLayer()
  netsend.login.createHero(self.m_CreateRoleType, self.m_CreateRoleName, self.m_CreateRoleHeroIdx, self.m_CreateRoleRandomTimes, self.m_CreateRoleEditFlag)
end
function CNetConnectMgr:_creathero(isSucceed)
  if isSucceed then
    netsend.login.createHero(self.m_CreateRoleType, self.m_CreateRoleName, self.m_CreateRoleHeroIdx, self.m_CreateRoleRandomTimes, self.m_CreateRoleEditFlag)
  end
end
function CNetConnectMgr:_autoReConnect()
  print("_autoReConnect-1")
  if not self:needAutoReconnect() then
    print("_autoReConnect -->> not need reconnect !!")
    return
  end
  print("_autoReConnect-2", self.m_AutoReconectTimes)
  if self.m_AutoReconectTimes > 0 then
    print("_autoReConnect-3")
    self.m_AutoReconectTimes = 0
    self:serverConnectFailed()
  else
    print("_autoReConnect-4")
    self.m_AutoReconectTimes = self.m_AutoReconectTimes + 1
    self.m_IsAutoReConnectAllServer = false
    scheduler.performWithDelayGlobal(function()
      print("CNetConnectMgr:自动重连..", self.m_ConnectType, self.m_IsDealingWithReconnect)
      SendMessage(MsgID_ReConnect_Ready_ReLogin)
      self:CloseConnect()
      local function listener(isSucceed)
        print("CNetConnectMgr:_autoReConnect, ConnectSvr:", isSucceed, self.m_IsDealingWithReconnect)
        if isSucceed then
          self:LoginToGameServer()
        end
      end
      print("----> listener:", tostring(listener))
      self:ConnectSvr(listener)
    end, 0.1)
  end
end
function CNetConnectMgr:_onCancelled()
  if CMainUIScene.Ins ~= nil then
    g_DataMgr:returnToLoginView()
  end
end
function CNetConnectMgr:getIsDealingWithReconnect()
  return self.m_IsDealingWithReconnect
end
function CNetConnectMgr:_autoReConnectAllServer()
  print("--->> _autoReConnectAllServer  start")
  self.m_IsAutoReConnectAllServer = true
  self:deleteLoadingLayer()
  g_NetConnectMgr:CloseConnect()
  self:ConnectDataServer(function()
    print("--->> _autoReConnectAllServer  dataServer conn succeed")
    self:_autoReConnect()
  end)
end
function CNetConnectMgr:OnMessage(msgSID, ...)
  if msgSID == MsgID_EnterBackground then
    self:onEnterBackground()
  elseif msgSID == MsgID_EnterForeground then
    self:onEnterForeground()
  elseif msgSID == MsgID_TCP_Event then
    local arg = {
      ...
    }
  elseif msgSID == MsgID_LoginResult then
    local arg = {
      ...
    }
    if arg[1] == LOGIN_SUCCEED then
      if self.m_IsDealingWithReconnect then
        self:resetConnectData(false)
      end
    else
      self:deleteLoadingLayer()
    end
  elseif msgSID == MsgID_LoginOut then
    self.m_IsLoginOut = true
  elseif msgSID == MsgID_Connect_SendFinished then
    if self.m_ConnectType == ConnectType_CreateRole or self.m_ConnectType == ConnectType_Register then
      self.m_ConnectType = ConnectType_Login
    end
    self:deleteLoadingLayer()
  end
end
function CNetConnectMgr:needAutoReconnect()
  return self.m_ReplacedDlg == nil and not self.m_IsLoginOut and not self.m_IsConnectDataServer
end
function CNetConnectMgr:onEnterBackground()
  if g_gameUpdate:isUpdateNotInGame() ~= true then
    self.m_IsBackground = true
  end
  self.m_LastEnterBackgroundTime = os.time()
end
function CNetConnectMgr:onEnterForeground()
  if not self.m_IsBackground then
    return
  end
  print("CNetConnectMgr:onEnterForeground:", self.m_IsBackground)
  if not self:needAutoReconnect() or g_DataMgr == nil or not g_DataMgr:IsInGame() then
    self.m_IsBackground = false
    print("self.m_ReplacedDlg:", self.m_ReplacedDlg)
    print("self.m_IsLoginOut:", self.m_IsLoginOut)
    print("self.m_IsConnectDataServer:", self.m_IsConnectDataServer)
    return
  end
  print("onEnterForeground:", self.m_IsBackground)
  if self.m_IsBackground then
    local curTime = os.time()
    local dt = curTime - self.m_LastEnterBackgroundTime
    if dt > 120 then
      print("---->>>>驻后台的时间大于2分钟，则直接关闭网络进入重连流程", dt)
      g_NetConnectMgr:CloseConnect()
      self:checkNetWork(false)
    else
      print("--->>>>驻后台的时间小于两分钟，则根据当前的链接情况进入ping或者重连", dt)
      self:checkNetWork(true)
    end
  end
  self.m_IsBackground = false
end
function CNetConnectMgr:checkNetWork(isForegournd)
  if g_gameUpdate:isUpdateNotInGame() == true then
    print("CNetConnectMgr:checkNetWork: 正在更新")
    self.m_IsDealingWithReconnect = false
    self.m_IsDealingCheckNetWork = false
    return
  end
  if self.m_IsDealingCheckNetWork then
    return
  end
  print("CNetConnectMgr:checkNetWork:g_DataMgr:IsInGame( ) =", g_DataMgr:IsInGame())
  self.m_IsDealingWithReconnect = true
  self.m_IsDealingCheckNetWork = true
  self:showLoadingLayer()
  scheduler.performWithDelayGlobal(function()
    print("checkNetWork run")
    self.m_IsDealingCheckNetWork = false
    if not self:isNetWorkAvailable() then
      print("checkNetWork no network")
      self:networkIsNotAvailable()
    elseif self.m_IsConnectGameServer == true then
      print("checkNetWork ping server")
      self:pingServer(isForegournd)
    else
      print("checkNetWork _autoReConnect")
      g_DataMgr:setIsSendFinished(false)
      self:_autoReConnect()
    end
  end, 0.3)
end
function CNetConnectMgr:onTcpStatusChanged(status)
  print("CNetConnectMgr:onTcpStatusChanged:", self.m_TcpStatus, status)
  if self.m_TcpStatus == status then
    return
  end
  self.m_TcpStatus = status
  if self.m_TcpStatus == NMGNET_STATUS_LOST or self.m_TcpStatus == NMGNET_STATUS_FAILED then
    self:ResetConnectFlag()
    self:checkNetWork(false)
  end
end
function CNetConnectMgr:pingServer(isForegournd)
  print("CNetConnectMgr:连接正常，开始ping服务器")
  netsend.netreconnect.pingToSvrOnEnterBackground()
  if self.m_PingSvrScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_PingSvrScheduler)
    self.m_PingSvrScheduler = nil
  end
  self.m_PingSvrScheduler = scheduler.performWithDelayGlobal(function()
    self:pingServerFailed(isForegournd)
  end, Define_PingSvrFailedTime)
end
function CNetConnectMgr:getPingFromSvr(svrtime)
  g_DataMgr:setServerTime(svrtime)
  self:resetConnectData()
  SendMessage(MsgID_ReConnect_PingSuccess)
end
function CNetConnectMgr:pingServerFailed(isForegournd)
  if self.m_IsBackground then
    return
  end
  if isForegournd == true then
    print("----->>后台回来的ping失败，则立即自动重练一次")
    g_NetConnectMgr:CloseConnect()
    self:checkNetWork(false)
  else
    print("----->>后台回来的ping失败，弹框")
    self:onSvrConnectFailed()
  end
end
function CNetConnectMgr:onSvrConnectFailed()
  g_NetConnectMgr:CloseConnect()
  if self:isNetWorkAvailable() then
    self:serverConnectFailed()
  else
    self:networkIsNotAvailable()
  end
end
function CNetConnectMgr:resetConnectData(delLoading)
  self.m_AutoReconectTimes = 0
  self.m_SendHeartBeatFlagDict = {}
  self.m_IsDealingWithReconnect = false
  self.m_IsDealingCheckNetWork = false
  if self.m_PingSvrScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_PingSvrScheduler)
    self.m_PingSvrScheduler = nil
  end
  if delLoading ~= false then
    self:deleteLoadingLayer()
  end
end
function CNetConnectMgr:resetLogicData()
  if CMainUIScene.Ins ~= nil then
    SendMessage(MsgID_ReConnect_ReLogin)
  end
end
function CNetConnectMgr:_onCancelled2()
  self:deleteLoadingLayer()
end
function CNetConnectMgr:networkIsNotAvailable(isOnlyShowConfirmBtn, confirmFunc)
  print("CNetConnectMgr:没有网络！")
  g_DataMgr:setIsSendFinished(false)
  self:deleteResultDlg()
  self:deleteLoadingLayer()
  if confirmFunc == nil then
    confirmFunc = handler(self, self._autoReConnect)
  end
  self.m_ResultDlg = CNetworkIsNotAvailableWarning.new({
    title = "网络异常",
    text = "与服务器断开连接,请检查你的网络设置",
    confirmFunc = confirmFunc,
    confirmText = "重试",
    cancelFunc = handler(self, self._onCancelled),
    cancelText = "取消",
    clearFunc = handler(self, self.onResultDlgClosed)
  })
  self.m_ResultDlg:ShowCloseBtn(false)
  if isOnlyShowConfirmBtn then
    self.m_ResultDlg:OnlyShowConfirmBtn()
  end
  self:resetConnectData(true)
  self.m_IsDealingWithReconnect = true
end
function CNetConnectMgr:serverConnectFailed()
  print("CNetConnectMgr:连接失败！")
  self.m_IsEnter = false
  self:deleteResultDlg()
  self:deleteLoadingLayer()
  self.m_ResultDlg = CPopWarning.new({
    title = "连接超时",
    text = "与服务器断开连接,请检查你的网络设置",
    confirmFunc = handler(self, self._autoReConnect),
    confirmText = "重试",
    cancelFunc = handler(self, self._onCancelled),
    cancelText = "取消",
    autoConfirmTime = 6,
    clearFunc = handler(self, self.onResultDlgClosed)
  })
  self.m_ResultDlg:ShowCloseBtn(false)
  self:resetConnectData(true)
  self.m_IsDealingWithReconnect = true
end
function CNetConnectMgr:serverConnectLost()
  print("CNetConnectMgr:连接中断！")
  self.m_IsEnter = false
  self:deleteResultDlg()
  self:deleteLoadingLayer()
  self.m_ResultDlg = CPopWarning.new({
    title = "服务器连接断开",
    text = "请稍候重新尝试连接",
    confirmFunc = handler(self, self._autoReConnect),
    confirmText = "重连",
    cancelFunc = handler(self, self._onCancelled),
    cancelText = "取消",
    autoConfirmTime = 6,
    clearFunc = handler(self, self.onResultDlgClosed)
  })
  self.m_ResultDlg:ShowCloseBtn(false)
  self:resetConnectData(true)
  self.m_IsDealingWithReconnect = true
end
function CNetConnectMgr:tokenError()
  print("CNetConnectMgr:tokenError")
  self.m_IsEnter = false
  self:deleteResultDlg()
  self:deleteLoadingLayer()
  local confirm = function()
    g_DataMgr:returnToLoginView()
    if LoginGame.Ins then
      LoginGame.Ins:LoginFailed()
    end
  end
  self.m_ResultDlg = CPopWarning.new({
    title = "登录失败",
    text = "登录超时，需要重新登录",
    confirmFunc = confirm,
    confirmText = "确定",
    cancelFunc = cancel
  })
  self.m_ResultDlg:ShowCloseBtn(false)
  self.m_ResultDlg:OnlyShowConfirmBtn()
  self:resetConnectData(true)
end
function CNetConnectMgr:showLoadingLayer(delayShow)
  if getCurSceneView() then
    getCurSceneView():ShowWaitingView(true, delayShow)
  end
end
function CNetConnectMgr:deleteLoadingLayer()
  if getCurSceneView() then
    getCurSceneView():HideWaitingView()
  end
end
function CNetConnectMgr:deleteResultDlg()
  if self.m_ResultDlg ~= nil then
    if self.m_ResultDlg.__isExist and self.m_ResultDlg.CloseSelf then
      self.m_ResultDlg:CloseSelf()
    end
    self.m_ResultDlg = nil
  end
end
function CNetConnectMgr:onResultDlgClosed(dlg)
  if self.m_ResultDlg == dlg then
    self.m_ResultDlg = nil
  end
end
function CNetConnectMgr:sendHeartBeat()
  if not g_DataMgr:IsInGame() then
    print("-->不发送心跳包: g_DataMgr:IsInGame():", g_DataMgr:IsInGame())
    return
  end
  if not self.m_IsConnectGameServer or self.m_IsBackground or self.m_IsDealingWithReconnect or self.m_ResultDlg ~= nil or self.m_ReplacedDlg ~= nil then
    self.m_SendHeartBeatFlagDict = {}
    print("-->不发送心跳包:")
    print("\t\t  self.m_IsConnectGameServer =", self.m_IsConnectGameServer)
    print("\t\t  self.m_IsBackground =", self.m_IsBackground)
    print("\t\t  self.m_IsDealingWithReconnect =", self.m_IsDealingWithReconnect)
    print("\t\t  self.m_ResultDlg =", self.m_ResultDlg)
    print("\t\t  self.m_ReplacedDlg =", self.m_ReplacedDlg)
    return
  end
  if not self:isNetWorkAvailable() then
    g_NetConnectMgr:CloseConnect()
    self:networkIsNotAvailable()
  end
  if self.m_TcpStatus == NMGNET_STATUS_SUCCEED then
    local unRecNum = 0
    for _, flag in pairs(self.m_SendHeartBeatFlagDict) do
      if flag then
        unRecNum = unRecNum + 1
      end
    end
    if unRecNum > 3 then
      print("CNetConnectMgr:三个心跳包没有收到回应，则准备断线重连")
      self.m_IsDealingWithReconnect = true
      self:onSvrConnectFailed()
    else
      local n = self:getNextHeartBeatFlag()
      self.m_SendHeartBeatFlagDict[n] = true
      netsend.netreconnect.heartbeatToSvr(n)
    end
  else
    print("-->不发送心跳包:")
    print("\t\t  self.m_TcpStatus =", self.m_TcpStatus, NMGNET_STATUS_SUCCEED)
  end
end
function CNetConnectMgr:getNextHeartBeatFlag()
  if self.m_HeartBeatNum == nil then
    self.m_HeartBeatNum = 0
  end
  self.m_HeartBeatNum = (self.m_HeartBeatNum + 1) % 10000
  return self.m_HeartBeatNum
end
function CNetConnectMgr:getHeartbeatFromSvr(n)
  if n ~= nil then
    self.m_SendHeartBeatFlagDict[n] = nil
  end
end
function CNetConnectMgr:loginReplaced()
  if self.m_ReplacedDlg ~= nil then
    return
  end
  self.m_IsDealingWithReconnect = true
  self.m_ReplacedDlg = CPopWarning.new({
    title = nil,
    text = "账号已在其他设备登录",
    confirmFunc = handler(self, self.onReplaceConfirm),
    confirmText = "确定",
    clearFunc = handler(self, self.onReplaceDlgClosed)
  })
  self.m_ReplacedDlg:ShowCloseBtn(false)
  self.m_ReplacedDlg:OnlyShowConfirmBtn()
  g_NetConnectMgr:CloseConnect()
  self:deleteResultDlg()
  self:deleteLoadingLayer()
end
function CNetConnectMgr:onReplaceConfirm()
  g_DataMgr:returnToLoginView()
  self:resetConnectData()
end
function CNetConnectMgr:onReplaceDlgClosed(dlg)
  if self.m_ReplacedDlg == dlg then
    self.m_ReplacedDlg = nil
  end
end
function CNetConnectMgr:onGameError(msg)
  if self.m_ReplacedDlg ~= nil then
    return
  end
  msg = msg or "检查到您有可能使用了辅助工具导致数据异常"
  self.m_IsDealingWithReconnect = true
  self.m_ReplacedDlg = CPopWarning.new({
    title = nil,
    text = msg,
    confirmFunc = handler(self, self.onReplaceConfirm),
    confirmText = "确定",
    clearFunc = handler(self, self.onReplaceDlgClosed)
  })
  self.m_ReplacedDlg:ShowCloseBtn(false)
  self.m_ReplacedDlg:OnlyShowConfirmBtn()
  g_NetConnectMgr:CloseConnect()
  self:deleteResultDlg()
  self:deleteLoadingLayer()
end
function CNetConnectMgr:Clean()
  if self.m_HbScheduler then
    scheduler.unscheduleGlobal(self.m_HbScheduler)
    self.m_HbScheduler = nil
  end
  self:RemoveAllMessageListener()
end
if g_NetConnectMgr then
  if g_NetConnectMgr.Clean then
    g_NetConnectMgr:Clean()
  elseif g_NetConnectMgr.m_HbScheduler then
    scheduler.unscheduleGlobal(g_NetConnectMgr.m_HbScheduler)
    g_NetConnectMgr.m_HbScheduler = nil
  end
end
g_NetConnectMgr = CNetConnectMgr.new()
CNetworkIsNotAvailableWarning = class("CNetworkIsNotAvailableWarning", CPopWarning)
function CNetworkIsNotAvailableWarning:ctor(para)
  CNetworkIsNotAvailableWarning.super.ctor(self, para)
  self.m_DetectScheduler = scheduler.scheduleGlobal(handler(self, self.detectNetWork), 1)
end
function CNetworkIsNotAvailableWarning:detectNetWork()
  if g_NetConnectMgr:isNetWorkAvailable() then
    self:OnBtn_Confirm()
  end
end
function CNetworkIsNotAvailableWarning:Clear()
  CNetworkIsNotAvailableWarning.super.Clear(self)
  if self.m_DetectScheduler then
    scheduler.unscheduleGlobal(self.m_DetectScheduler)
    self.m_DetectScheduler = nil
  end
end
