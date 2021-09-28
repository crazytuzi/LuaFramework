local Define_HeartBeatCD = 10
local Define_PingSvrFailedTime = 10
local ConnectType_None = 0
local ConnectType_Login = 1
local ConnectType_Register = 2
local ConnectType_CreateRole = 3
local CNetConnectMgr = class("CNetConnectMgr", nil)
function CNetConnectMgr:ctor()
  self.m_LastIp = ""
  self.m_LastPort = ""
  self.m_Account = ""
  self.m_Password = ""
  self.m_TcpStatus = nil
  self.m_ConnectType = ConnectType_None
  self.m_IsBackground = false
  self.m_IsDealingWithReconnect = false
  self.m_SendHeartBeatCnt = 0
  self.m_ResultDlg = nil
  self.m_ReplacedDlg = nil
  self.m_IsLoginOut = false
  self.m_ConnectSucceedFunc = nil
  self.m_IsCanSendProtocol = false
  self.m_HbScheduler = scheduler.scheduleGlobal(handler(self, self.sendHeartBeat), Define_HeartBeatCD)
  self.m_PingSvrScheduler = nil
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Device)
  self:ListenMessage(MsgID_Connect)
end
function CNetConnectMgr:isNetWorkAvailable()
  return network.isLocalWiFiAvailable() or network.isInternetConnectionAvailable()
end
function CNetConnectMgr:getIpAndPort()
  return self.m_LastIp, self.m_LastPort
end
function CNetConnectMgr:_ConnectSvr(sucFunc, listener)
  local ip = getConfigByName("lastSerIp")
  local port = getConfigByName("lastSerPort")
  self.m_IsLoginOut = false
  if not self:isNetWorkAvailable() then
    netconn:close()
    self:networkIsNotAvailable()
    return
  end
  if self.m_TcpStatus == NMGNET_STATUS_SUCCEED then
    if self.m_LastIp == ip and self.m_LastPort == port then
      self:_onConnectSvr(NMGNET_STATUS_SUCCEED, ip, port, sucFunc, listener, true)
      return
    else
      netconn:close()
    end
  end
  self.m_IsCanSendProtocol = false
  print("CNetConnectMgr:开始链接服务器:", ip, port)
  self:showLoadingLayer()
  netconn:connect(function(status)
    print("CNetConnectMgr:netconn connect status:", status, ip, port, sucFunc, listener)
    netconn.m_connResultListerner = nil
    self:_onConnectSvr(status, ip, port, sucFunc, listener)
  end, ip, port)
end
function CNetConnectMgr:_onConnectSvr(status, ip, port, sucFunc, listener, oldConn)
  self.m_TcpStatus = status
  if status == NMGNET_STATUS_SUCCEED then
    self.m_LastIp = ip
    self.m_LastPort = port
    self:deleteResultDlg()
    if oldConn == true then
      if sucFunc then
        sucFunc()
      end
      if listener then
        listener(true)
      end
    else
      self.m_ConnectSucceedFunc = {sucFunc, listener}
    end
  elseif status == NMGNET_STATUS_LOST then
    self:deleteLoadingLayer()
    self:serverConnectLost()
    if listener then
      listener(false)
    end
  elseif status == NMGNET_STATUS_FAILED then
    self:deleteLoadingLayer()
    self:serverConnectFailed()
    if listener then
      listener(false)
    end
  end
  self:onTcpStatusChanged(status)
end
function CNetConnectMgr:ConnectSvr()
  self.m_ConnectType = ConnectType_None
  self:_ConnectSvr()
end
function CNetConnectMgr:ConnectSvrAndLogin(account, password, listener)
  self:deleteLoadingLayer()
  self.m_ConnectType = ConnectType_Login
  self.m_Account = account
  self.m_Password = password
  self:_ConnectSvr(handler(self, self._login), listener)
end
function CNetConnectMgr:_login()
  self:showLoadingLayer()
  if self.m_IsDealingWithReconnect then
    self:resetLogicData()
  end
  netsend.login.login(self.m_Account, self.m_Password)
  g_DataMgr:StartLogin(self.m_Account, self.m_Password)
end
function CNetConnectMgr:ProtocolEncryptFinish()
  self.m_IsCanSendProtocol = true
  if self.m_ConnectSucceedFunc then
    for k, v in pairs(self.m_ConnectSucceedFunc) do
      v(true)
    end
  end
end
function CNetConnectMgr:ConnectSvrAndRegister(account, pwd)
  self.m_ConnectType = ConnectType_Register
  self.m_Account = account
  self.m_Password = pwd
  self:_ConnectSvr(handler(self, self._register))
end
function CNetConnectMgr:_register()
  netsend.login.register(self.m_Account, self.m_Password)
  g_DataMgr:setLoginInfo(self.m_Account, self.m_Password)
end
function CNetConnectMgr:ConnectSvrAndCreatRole(roleType, name)
  self.m_ConnectType = ConnectType_CreateRole
  self.m_CreateRoleType = roleType
  self.m_CreateRoleName = name
  self:_ConnectSvr(handler(self, self._creathero))
end
function CNetConnectMgr:_creathero()
  local heroindex = 0
  netsend.login.createHero(self.m_CreateRoleType, self.m_CreateRoleName, heroindex)
end
function CNetConnectMgr:_autoReConnect()
  if not self:needAutoReconnect() then
    return
  end
  scheduler.performWithDelayGlobal(function()
    print("CNetConnectMgr:自动重连..", self.m_ConnectType)
    SendMessage(MsgID_ReConnect_Ready_ReLogin)
    if self.m_ConnectType == ConnectType_Login then
      self:_ConnectSvr(handler(self, self._login))
    elseif self.m_ConnectType == ConnectType_Register then
      self:_ConnectSvr(handler(self, self._register))
    elseif self.m_ConnectType == ConnectType_CreateRole then
      self:_ConnectSvr(handler(self, self._creathero))
    else
      self:_ConnectSvr()
    end
  end, 0.1)
end
function CNetConnectMgr:_onCancelled()
  if CMainUIScene.Ins ~= nil then
    g_DataMgr:returnToLoginView()
  end
end
function CNetConnectMgr:getIsDealingWithReconnect()
  return self.m_IsDealingWithReconnect
end
function CNetConnectMgr:OnMessage(msgSID, ...)
  if msgSID == MsgID_EnterBackground then
    self:onEnterBackground()
  elseif msgSID == MsgID_EnterForeground then
  elseif msgSID == MsgID_TCP_Event then
    local arg = {
      ...
    }
    self:onTcpStatusChanged(arg[1])
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
  return self.m_ReplacedDlg == nil and not self.m_IsLoginOut
end
function CNetConnectMgr:onEnterBackground()
  self.m_IsBackground = true
end
function CNetConnectMgr:onEnterForeground()
  if not self:needAutoReconnect() then
    self.m_IsBackground = false
    return
  end
  if self.m_IsBackground then
    self:showLoadingLayer()
    scheduler.performWithDelayGlobal(handler(self, self.checkNetWork), 0.3)
  end
end
function CNetConnectMgr:checkNetWork()
  self.m_IsBackground = false
  self.m_IsDealingWithReconnect = true
  if not self:isNetWorkAvailable() then
    self:networkIsNotAvailable()
  elseif self.m_TcpStatus == NMGNET_STATUS_SUCCEED then
    self:pingServer()
  else
    self:_autoReConnect()
  end
end
function CNetConnectMgr:onTcpStatusChanged(status)
  print("CNetConnectMgr:onTcpStatusChanged:", self.m_TcpStatus, status)
  if status ~= NMGNET_STATUS_SUCCEED and status ~= NMGNET_STATUS_LOST and status ~= NMGNET_STATUS_FAILED then
    return
  end
  if self.m_TcpStatus == status then
    return
  end
  self.m_TcpStatus = status
  if not self:needAutoReconnect() then
    return
  end
  if self.m_TcpStatus == NMGNET_STATUS_SUCCEED then
  elseif self.m_TcpStatus == NMGNET_STATUS_LOST then
    if not self.m_IsBackground then
      if self.m_IsDealingWithReconnect then
        print("CNetConnectMgr:重连失败")
        self:serverConnectLost()
      else
        print("CNetConnectMgr:游戏过程中链接中断，自动重连")
        self.m_IsDealingWithReconnect = true
        self:_autoReConnect()
      end
    end
  elseif self.m_TcpStatus == NMGNET_STATUS_FAILED and not self.m_IsBackground then
    if self.m_IsDealingWithReconnect then
      print("CNetConnectMgr:重连失败")
      self:serverConnectFailed()
    else
      print("CNetConnectMgr:游戏过程中链接中断，自动重连")
      self.m_IsDealingWithReconnect = true
      self:_autoReConnect()
    end
  end
end
function CNetConnectMgr:pingServer()
  print("CNetConnectMgr:连接正常，开始ping服务器")
  netsend.netreconnect.pingToSvrOnEnterBackground()
  if self.m_PingSvrScheduler ~= nil then
    scheduler.unscheduleGlobal(self.m_PingSvrScheduler)
    self.m_PingSvrScheduler = nil
  end
  self.m_PingSvrScheduler = scheduler.performWithDelayGlobal(handler(self, self.pingServerFailed), Define_PingSvrFailedTime)
end
function CNetConnectMgr:getPingFromSvr(svrtime)
  g_DataMgr:setServerTime(svrtime)
  self:resetConnectData()
  SendMessage(MsgID_ReConnect_PingSuccess)
end
function CNetConnectMgr:pingServerFailed()
  if self.m_IsBackground then
    return
  end
  self:onSvrConnectFailed()
end
function CNetConnectMgr:onSvrConnectFailed()
  netconn:close()
  if self:isNetWorkAvailable() then
    self:serverConnectFailed()
  else
    self:networkIsNotAvailable()
  end
end
function CNetConnectMgr:resetConnectData(delLoading)
  self.m_SendHeartBeatCnt = 0
  self.m_IsDealingWithReconnect = false
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
function CNetConnectMgr:networkIsNotAvailable()
  print("CNetConnectMgr:没有网络！")
  self:deleteResultDlg()
  self:deleteLoadingLayer()
  self.m_ResultDlg = CPopWarning.new({
    title = "网络异常",
    text = "当前网络不可用！",
    confirmFunc = handler(self, self._autoReConnect),
    confirmText = "重试",
    cancelFunc = handler(self, self._onCancelled),
    cancelText = "取消",
    clearFunc = handler(self, self.onResultDlgClosed)
  })
  self.m_ResultDlg:ShowCloseBtn(false)
end
function CNetConnectMgr:serverConnectFailed()
  print("CNetConnectMgr:链接失败！")
  self:deleteResultDlg()
  self:deleteLoadingLayer()
  self.m_ResultDlg = CPopWarning.new({
    title = "服务器链接失败",
    text = "请稍候重新尝试链接",
    confirmFunc = handler(self, self._autoReConnect),
    confirmText = "重连",
    cancelFunc = handler(self, self._onCancelled),
    cancelText = "取消",
    clearFunc = handler(self, self.onResultDlgClosed)
  })
  self.m_ResultDlg:ShowCloseBtn(false)
end
function CNetConnectMgr:serverConnectLost()
  print("CNetConnectMgr:链接中断！")
  self:deleteResultDlg()
  self:deleteLoadingLayer()
  self.m_ResultDlg = CPopWarning.new({
    title = "服务器链接断开",
    text = "请稍候重新尝试链接",
    confirmFunc = handler(self, self._autoReConnect),
    confirmText = "重连",
    cancelFunc = handler(self, self._onCancelled),
    cancelText = "取消",
    clearFunc = handler(self, self.onResultDlgClosed)
  })
  self.m_ResultDlg:ShowCloseBtn(false)
end
function CNetConnectMgr:showLoadingLayer()
  if getCurSceneView() then
    getCurSceneView():ShowWaitingView()
  end
end
function CNetConnectMgr:deleteLoadingLayer()
  if getCurSceneView() then
    getCurSceneView():HideWaitingView()
  end
end
function CNetConnectMgr:deleteResultDlg()
  if self.m_ResultDlg ~= nil then
    self.m_ResultDlg:removeFromParentAndCleanup(true)
  end
end
function CNetConnectMgr:onResultDlgClosed(dlg)
  if self.m_ResultDlg == dlg then
    self.m_ResultDlg = nil
  end
end
function CNetConnectMgr:sendHeartBeat()
  if self.m_IsCanSendProtocol ~= true then
    return
  end
  if self.m_IsBackground or self.m_IsDealingWithReconnect or self.m_ResultDlg ~= nil or self.m_ReplacedDlg ~= nil then
    self.m_SendHeartBeatCnt = 0
    return
  end
  if not self:isNetWorkAvailable() then
    netconn:close()
    self:networkIsNotAvailable()
  end
  if self.m_SendHeartBeatCnt < 0 then
    self.m_SendHeartBeatCnt = 0
  end
  if self.m_TcpStatus == NMGNET_STATUS_SUCCEED then
    self.m_SendHeartBeatCnt = self.m_SendHeartBeatCnt + 1
    if self.m_SendHeartBeatCnt > 3 then
      print("CNetConnectMgr:连续三个心跳包没有收到回应，则准备断线重连")
      self.m_IsDealingWithReconnect = true
      self:onSvrConnectFailed()
    else
      netsend.netreconnect.heartbeatToSvr()
    end
  end
end
function CNetConnectMgr:getHeartbeatFromSvr()
  self.m_SendHeartBeatCnt = self.m_SendHeartBeatCnt - 1
  if self.m_SendHeartBeatCnt < 0 then
    self.m_SendHeartBeatCnt = 0
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
  netconn:close()
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
g_NetConnectMgr = CNetConnectMgr.new()
