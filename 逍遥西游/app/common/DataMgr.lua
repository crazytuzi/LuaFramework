local DataMgr = class("DataMgr")
local g_ServerData = {
  m_ServerList = nil,
  m_ServerIdSeq = nil,
  m_ServerRoles = nil,
  m_ChoosedLoginServerId = nil,
  m_ChoosedLoginServerNetInfo = nil,
  m_ChoosedLoginPayKid = nil,
  m_AccountType = AccountType_Unknown,
  m_DataServerToken = nil,
  m_LoginAccount = nil,
  m_LoginPwd = nil,
  m_ServerLoginAccount = nil,
  m_ServerRoleNum = 0,
  m_ServerRoleList = nil,
  m_tcb = nil
}
function DataMgr:ctor()
  self.m_CurConnectDataServerIdx = 0
  self.m_DevicePlatformType = channel.devicePlatformType
  self.m_Players = {}
  self.m_ServerTime = 0
  self.m_LocalTime = 0
  self.m_LoginStatus = 0
  self.m_IsSendFinished = false
  self.m_LastLoginUDID = 0
  self.m_IsInGame = false
  self.m_SyncPlayerType = SyncPlayerType_Min
  self.m_IsBackGroud = false
  self.isPaying = false
  MessageEventExtend.extend(self)
  self:ListenMessage(MsgID_Device)
  self:ListenMessage(MsgID_Connect)
  self:ListenMessage(MsgID_PlayerInfo)
  self.m_DetectAcceleratorTime = 10
  self.m_DetectAcceleratorTimer = 0
  self.m_DetectAcceleratorServerTime = -1
  self.m_IsWaittingServerTime = false
  self.m_LoginToRoleIdForReConnectServer = nil
  self.m_CreateRoleIdForReConnectServer = nil
  self.m_isNewRole = false
  self.m_FinishedEventData = {}
  self.m_NotFinishedEventNum = 0
end
function DataMgr:frameUpdata(dt)
  self:DetectAcceleratorUpdate(dt)
end
function DataMgr:ClearAllPlayer()
  local allPlayerID = {}
  for pid, _ in pairs(self.m_Players) do
    allPlayerID[#allPlayerID + 1] = pid
  end
  for _, pid in pairs(allPlayerID) do
    self:delPlayer(pid)
  end
end
function DataMgr:CreatePlayer(roleId, isLocal)
  if isLocal and self.m_Players[roleId] ~= nil then
    return self.m_Players[roleId]
  end
  local player = Player.new(roleId, isLocal)
  if isLocal then
    player.m_Account = g_ServerData.m_LoginAccount
    player.m_Pwd = g_ServerData.m_LoginPwd
    g_LocalPlayer = player
  end
  self.m_Players[roleId] = player
  return player
end
function DataMgr:getPlayer(roleId)
  if roleId then
    return self.m_Players[roleId]
  end
  return g_LocalPlayer
end
function DataMgr:delPlayer(roleId)
  local player = self.m_Players[roleId]
  if player then
    if player.DelTiliTimer then
      player:DelTiliTimer()
    end
    if player.DelBoxTimer then
      player:DelBoxTimer()
    end
    if player.DelFuWenTimer then
      player:DelFuWenTimer()
    end
    if player.DelChengweiUpdateTimer then
      player:DelChengweiUpdateTimer()
    end
    if player.DelXianGouUpdateTimer then
      player:DelXianGouUpdateTimer()
    end
    if player.DelJiaYiWanUpdateTimer then
      player:DelJiaYiWanUpdateTimer()
    end
    if player.DelExtraExpUpdateTimer then
      player:DelExtraExpUpdateTimer()
    end
    self.m_Players[roleId] = nil
    g_TeamMgr:deleteTeamInfoWhenPlayerHide(roleId)
    return true
  end
  return false
end
function DataMgr:getAllPlayers()
  return self.m_Players
end
function DataMgr:GameLoginFinish(mapId, pos, posType)
  self.m_LoginStatus = 2
  if mapId and pos and #pos == 2 then
    self.m_InitMapAndPos = {
      mapId,
      pos,
      posType
    }
  end
end
function DataMgr:getInitMapAndPos()
  return self.m_InitMapAndPos
end
function DataMgr:getLoginAccount()
  return g_ServerData.m_LoginAccount
end
function DataMgr:getServerLoginAccount()
  if g_ServerData.m_ServerLoginAccount and g_ServerData.m_ServerLoginAccount ~= "" then
    return g_ServerData.m_ServerLoginAccount
  else
    return self:getLoginAccount()
  end
end
function DataMgr:setServerLoginAccount(sAccount)
  g_ServerData.m_ServerLoginAccount = sAccount
end
function DataMgr:ServerNotifyMsg(msg)
  printLog("DataMgr", "serverMsg:%s", msg)
end
function DataMgr:setLoginInfo(account, pwd)
  g_ServerData.m_LoginAccount = account
  g_ServerData.m_LoginPwd = pwd
end
function DataMgr:setLoginWithMomo()
  g_ServerData.m_AccountType = AccountType_Momo
end
function DataMgr:setLoginWithChannel()
  g_ServerData.m_AccountType = AccountType_Channel
end
function DataMgr:setLoginWithNmg(account, pwd)
  g_ServerData.m_AccountType = AccountType_Nmg
  g_ServerData.m_LoginAccount = account
  g_ServerData.m_LoginPwd = pwd
end
function DataMgr:getAccountType()
  return g_ServerData.m_AccountType
end
function DataMgr:getDataServerTokenAndCb()
  return g_ServerData.m_DataServerToken, g_ServerData.m_tcb
end
function DataMgr:StartLoginDataServer()
  local isConnect = false
  if g_ServerData.m_AccountType == AccountType_Channel then
    print("DataMgr:StartLoginDataServer Channel Login:")
    g_ChannelMgr:sendLoginProtocol(GameType, self:getDeviceType())
    isConnect = true
  elseif g_ServerData.m_AccountType == AccountType_Momo then
    local userID, token, uType = g_MomoMgr:getAccountInfo()
    print("DataMgr:loginToDataServerWithMomo:", userID, token, uType)
    if userID and token then
      netsend.netaccount.loginMomo(GameType, userID, token, self:getDeviceType())
      isConnect = true
    end
  elseif g_ServerData.m_AccountType == AccountType_Nmg and g_ServerData.m_LoginAccount and g_ServerData.m_LoginPwd then
    local m_mk = SyNative.getNMGMk()
    netsend.netaccount.loginNmg(GameType, g_ServerData.m_LoginAccount, g_ServerData.m_LoginPwd, m_mk)
    isConnect = true
  end
  if isConnect == false then
    ShowNotifyViewsNotInWar("登录信息异常，请重新登录", true)
    g_NetConnectMgr:deleteLoadingLayer()
  end
end
function DataMgr:loginToDataServerWithMomo()
  local userID, token, uType = g_MomoMgr:getAccountInfo()
  print("DataMgr:loginToDataServerWithMomo:", userID, token, uType)
  if userID == nil or token == nil then
    return false
  else
    netsend.netaccount.loginMomo(GameType, userID, token, self:getDeviceType())
    return true
  end
end
function DataMgr:loginToDataServerWithNmg(account, pwd)
  g_ServerData.m_LoginAccount = account
  g_ServerData.m_LoginPwd = pwd
  local m_mk = SyNative.getNMGMk()
  netsend.netaccount.loginNmg(GameType, account, pwd, m_mk)
end
function DataMgr:registerToDataServerWithNmg(account, pwd)
  g_ServerData.m_LoginAccount = account
  g_ServerData.m_LoginPwd = pwd
  local m_mk = SyNative.getNMGMk()
  netsend.netaccount.register(GameType, account, pwd, m_mk)
end
function DataMgr:getNmgAccount()
  return g_ServerData.m_LoginAccount, g_ServerData.m_LoginPwd
end
function DataMgr:RegisterDataServerResult(resultType, info)
  print("[DataMgr] RegisterResult,", resultType, info)
  if resultType == 1 then
    setLoginAccountAndPwd(g_ServerData.m_LoginAccount, g_ServerData.m_LoginPwd)
  else
  end
  SendMessage(MsgID_RegResult, resultType == 1, info)
end
function DataMgr:getDeviceType()
  if self.m_DevicePlatformType == nil then
    self.m_DevicePlatformType = 0
    if device.platform == "ios" then
      self.m_DevicePlatformType = 1
      local deviceName = SyNative.getDeviceName()
      print("deviceName:", deviceName)
      if deviceName == "x86_64" then
        self.m_DevicePlatformType = 0
      end
    elseif device.platform == "android" then
      self.m_DevicePlatformType = 2
    end
  end
  print("getDeviceType-->self.m_DevicePlatformType:", self.m_DevicePlatformType)
  return self.m_DevicePlatformType
end
function DataMgr:LoginResultByDataServer(loginType, resultType, msg, s_token, t_cb)
  local loginT = 0
  if resultType == 1 then
    g_ServerData.m_AccountType = loginType
    g_ServerData.m_DataServerToken = s_token
    g_ServerData.m_tcb = t_cb
    loginT = LOGIN_SUCCEED
    if g_ServerData.m_LoginAccount and g_ServerData.m_LoginPwd then
      setLoginAccountAndPwd(g_ServerData.m_LoginAccount, g_ServerData.m_LoginPwd)
    end
  elseif resultType == 2 then
    loginT = LOGIN_ACCOUNTNOTEXIST
    device.showAlert("登录失败", "找不到帐号", {"确定"}, nil)
  elseif resultType == 3 then
    loginT = LOGIN_PWDERROR
    device.showAlert("登录失败", "密码错误", {"确定"}, nil)
  elseif resultType == 4 then
    loginT = LOGIN_ServieFixing
    device.showAlert("登录失败", "服务器正在维护", {"确定"}, function()
      if CMainUIScene.Ins ~= nil then
      end
    end)
  elseif resultType == 5 then
    loginT = LOGIN_Other
    if msg == nil or type(msg) ~= "string" then
      msg = "登录过程发生了异常，请重新登录"
    end
    device.showAlert("登录失败", msg, {"确定"}, nil)
  end
  printLog("DataMgr", "LoginResultByDataServer loginType=%d, loginT=%d", loginType, loginT)
  SendMessage(MsgID_LoginResult, loginT)
end
function DataMgr:HadGetServerList(serList)
  local serTable = {}
  local serIds = {}
  for k, data in ipairs(serList) do
    local kid = data.kid
    serIds[#serIds + 1] = kid
    serTable[kid] = data
  end
  g_ServerData.m_ServerList = serTable
  g_ServerData.m_ServerIdSeq = serIds
  SendMessage(MsgID_HadGetServerList)
  dump(g_ServerData.m_ServerList, "g_ServerData.m_ServerList")
  dump(g_ServerData.m_ServerIdSeq, "g_ServerData.m_ServerIdSeq")
end
function DataMgr:HadGetServerRoles(serRoleList)
  local roleTable = {}
  for k, data in ipairs(serRoleList) do
    local kid = data.kid
    local lvInfo = {
      zs = data.rb,
      lv = data.lv,
      shapeId = data.rtype
    }
    if roleTable[kid] == nil then
      roleTable[kid] = {lvInfo}
    else
      roleTable[kid][#roleTable[kid] + 1] = lvInfo
    end
  end
  g_ServerData.m_ServerRoles = roleTable
  dump(g_ServerData.m_ServerRoles, "g_ServerData.m_ServerRoles")
  SendMessage(MsgID_DataServer_SendServerList)
end
function DataMgr:getServerList()
  return g_ServerData.m_ServerList, g_ServerData.m_ServerIdSeq
end
function DataMgr:getServerRoleList()
  return g_ServerData.m_ServerRoles
end
function DataMgr:LoginToServer(serverId)
  if g_ServerData.m_ServerList == nil then
    return false
  end
  if serverId == nil then
    serverId = g_ServerData.m_ChoosedLoginServerId
  end
  local serverData = g_ServerData.m_ServerList[serverId]
  print("serverData, g_ServerData.m_DataServerToken:", serverData, g_ServerData.m_DataServerToken)
  if serverData == nil or g_ServerData.m_DataServerToken == nil then
    return false
  end
  local ip = serverData.ip
  local port = serverData.port
  g_ServerData.m_ChoosedLoginServerNetInfo = {ip, port}
  g_ServerData.m_ChoosedLoginServerId = serverId
  if serverData.skid == nil then
    g_ServerData.m_ChoosedLoginPayKid = serverId
  else
    print("serverData.skid:", serverData.skid)
    g_ServerData.m_ChoosedLoginPayKid = serverData.skid
  end
  print("g_ServerData.m_ChoosedLoginPayKid:", g_ServerData.m_ChoosedLoginPayKid)
  self.m_LoginStatus = 0
  self.m_IsSendFinished = false
  g_NetConnectMgr:ConnectServerAndLogin()
  return true
end
function DataMgr:loginGameServerResult(isSucceed)
end
function DataMgr:setLoginInfoToChannel()
  print("-->>setLoginInfoToChannel:")
  local serverId = g_ServerData.m_ChoosedLoginServerId
  local serverName = self:getLoginServerName() or "未知服务器"
  local pid = g_LocalPlayer:getPlayerId()
  local lv = g_LocalPlayer:getObjProperty(1, PROPERTY_ROLELEVEL)
  local roleName = g_LocalPlayer:getObjProperty(1, PROPERTY_NAME)
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
    roleId = pid,
    roleName = roleName,
    roleLv = lv,
    bpName = bpid,
    balance = mbalance,
    viplv = vipLv
  }
  dump(data, "data")
  g_ChannelMgr:setGameServer(data)
  g_ChannelMgr:sendRoleInfoAfterLogin(data)
  g_ChannelMgr:RoleLevelUp(data)
  g_ChannelMgr:showToolBar(ChannelToolBarPlace.kToolBarTopLeft)
end
function DataMgr:getChoosedLoginServerInfo()
  if g_ServerData.m_ChoosedLoginServerNetInfo == nil then
    return nil, nil, nil
  end
  return g_ServerData.m_ChoosedLoginServerId, g_ServerData.m_ChoosedLoginServerNetInfo[1], g_ServerData.m_ChoosedLoginServerNetInfo[2], g_ServerData.m_ChoosedLoginPayKid
end
function DataMgr:getLoginServerName()
  if g_ServerData.m_ServerList == nil then
    return nil
  end
  local serverData = g_ServerData.m_ServerList[g_ServerData.m_ChoosedLoginServerId]
  if serverData then
    return serverData.name
  end
end
function DataMgr:StartLogin(account, pwd)
  self.m_LoginStatus = 0
  self:setLoginInfo(account, pwd)
  self.m_IsSendFinished = false
end
function DataMgr:LoginResult(loginType)
  local loginT = 0
  if loginType == 1 then
    loginT = LOGIN_SUCCEED
    setLoginAccountAndPwd(g_ServerData.m_LoginAccount, g_ServerData.m_LoginPwd)
  elseif loginType == 2 then
    loginT = LOGIN_ACCOUNTNOTEXIST
    device.showAlert("登录失败", "找不到帐号", {"确定"}, nil)
  elseif loginType == 3 then
    loginT = LOGIN_PWDERROR
    device.showAlert("登录失败", "密码错误", {"确定"}, nil)
  elseif loginType == 4 then
    loginT = LOGIN_ServieFixing
    device.showAlert("登录失败", "服务器正在维护", {"确定"}, function()
      if CMainUIScene.Ins ~= nil then
        self:returnToLoginView()
      end
    end)
  end
  printLog("DataMgr", "loginType=%d, loginT=%d", loginType, loginT)
  SendMessage(MsgID_LoginResult, loginT)
end
function DataMgr:RegisterResult(isSucceed, info)
  print("[DataMgr] RegisterResult,", isSucceed, info)
  if isSucceed then
    setLoginAccountAndPwd(g_ServerData.m_LoginAccount, g_ServerData.m_LoginPwd)
  else
  end
  SendMessage(MsgID_RegResult, isSucceed, info)
end
function DataMgr:getRoleInfoFromSvr(roleNum, roleTable)
  print("DataMgr:getRoleInfoFromSvr", roleNum, roleTable)
  g_ServerData.m_ServerRoleNum = roleNum
  g_ServerData.m_ServerRoleList = roleTable
  if roleNum == nil or roleTable == nil then
    self.m_LoginStatus = 1
    ShowLoginView()
    device.showAlert("登录失败", "服务器错误，请稍候再试", {"确定"}, nil)
    return
  end
  if self.m_CreateRoleIdForReConnectServer == true then
    self.m_CreateRoleIdForReConnectServer = nil
    g_NetConnectMgr:ConnectSvrAndCreatRole(self.m_CreateRoleType, self.m_CreateRoleName, self.m_CreateRoleHeroIdx, self.m_CreateRoleRandomTimes, self.m_CreateRoleEditFlag)
    return
  end
  if roleNum == 0 then
    self:ShowNewRoleView()
  elseif roleNum > 1 then
    self:ShowServerRoleListView()
  elseif getLastLoginServerId() == g_ServerData.m_ChoosedLoginServerId then
    if self.m_LoginToRoleIdForReConnectServer then
      self:EnterGameWithRoleId(self.m_LoginToRoleIdForReConnectServer)
      self.m_LoginToRoleIdForReConnectServe = nil
    else
      self:EnterGameWithRoleId()
    end
  else
    self:ShowServerRoleListView()
  end
  SendMessage(MsgID_HadGetRoleInfoFromSvr, roleNum)
end
function DataMgr:ShowServerRoleListView()
  LoginRoleList.new(g_ServerData.m_ServerRoleList):Show()
end
function DataMgr:ShowNewRoleView()
  CNewRole.new(g_ServerData.m_ServerRoleNum + 1):Show()
end
function DataMgr:LogoutAndShowServerRoleListView()
  printLog("DataMgr", "LogoutAndShowServerRoleListView")
  self:resetAllData()
  gamereset.resetAll()
  scheduler.performWithDelayGlobal(function()
    self:ShowServerRoleListView()
  end, 0.01)
end
function DataMgr:getAllRolesInfoStartWhenLogin(lastUDID)
  self.m_LastLoginUDID = lastUDID
  if self.m_IsInGame and lastUDID ~= device.getOpenUDID() then
    print("---->>>>>>>>getAllRolesInfoStartWhenLogin 游戏需要重新加载!!!!!!!", lastUDID, device.getOpenUDID())
    CMainUIScene.Ins = nil
    local scene = display.getRunningScene()
    scene:removeAllChildren()
    gamereset.resetAll(true)
  end
end
function DataMgr:getAllRolesInfoFinishedWhenLogin()
  self.m_IsInGame = true
  self.m_InitMapAndPos = self.m_InitMapAndPos or {}
  local mapId, pos, posType = unpack(self.m_InitMapAndPos)
  if mapId == nil or pos == nil then
    mapId = 1
    pos = {14, 22}
    posType = MapPosType_EditorGrid
  end
  local isLoadMap = true
  if activity.tianting:isInFb() == true then
    isLoadMap = false
  end
  if isLoadMap or g_CMainMenuHandler == nil then
    g_MapMgr:LoadMapById(mapId, pos, posType)
  end
  self.m_IsSendFinished = true
  g_MissionMgr:FlushCanAcceptMission()
  g_MissionMgr:flushMissionStatusForNpc()
  g_CanGetNewPetFlag = true
  g_NetConnectMgr:deleteLoadingLayer()
  preLoadWarUI()
  activity.keju:checkIsShowDianshiReadyBtn()
  self:setLoginInfoToChannel()
  SendMessage(MsgID_Connect_SendFinished)
  if g_MissionMgr then
    g_MissionMgr:intGuideData()
  end
end
function DataMgr:getLastLoginUDID()
  return self.m_LastLoginUDID
end
function DataMgr:addRole(roleId, roleType, roleName, isLocal)
  if isLocal == nil then
    isLocal = true
  end
  print("DataMgr:addRole", roleId, roleType, roleName, isLocal)
  local player
  if isLocal == true then
    local roleList = g_ServerData.m_ServerRoleList
    if roleList == nil then
      roleList = {}
    end
    roleList[#roleList + 1] = {
      i_roleid = roleId,
      i_rtype = roleType,
      s_name = roleName,
      i_zs = 0,
      i_lv = 0
    }
    g_ServerData.m_ServerRoleList = roleList
    g_ServerData.m_ServerRoleNum = #roleList
    self:EnterGameWithRoleId(roleId)
  else
    player = self:_createLocalPlayer(roleId, roleType, roleName, isLocal)
  end
  return player
end
function DataMgr:_createLocalPlayer(roleId, roleType, roleName, isLocal)
  if isLocal == nil then
    isLocal = true
  end
  local player = self:CreatePlayer(roleId, isLocal)
  player.m_RoleType = roleType
  player.m_RoleName = roleName
  if isLocal then
    self.m_EnterRoleInfo = {
      roleId,
      roleType,
      roleName
    }
  end
  return player
end
function DataMgr:_EnterLocalPlayer()
  local deviceName = SyNative.getDeviceName()
  local syncType = getSyncPlayerTypeFromConfig()
  print("-->> _EnterLocalPlayer:saved type =", syncType)
  if syncType == nil then
    local dInfo = data_DeviceInfo[deviceName]
    if dInfo then
      syncType = dInfo.syncType
    end
    if syncType == nil then
      local totalMem = SyNative.getMemoryInfo()
      print("----->> totalMem:", totalMem)
      if totalMem >= 1999 then
        syncType = SyncPlayerType_Max
      elseif totalMem > 1024 then
        syncType = SyncPlayerType_Middle
      else
        syncType = SyncPlayerType_Min
      end
    end
    print("-->> syncType:", syncType)
    if syncType == SyncPlayerType_Min then
      print("-->> 内存过低全部用中间显示模式:", syncType)
      syncType = SyncPlayerType_Middle
    end
    print("-->> syncType:", syncType)
    self:SyncPlayerTypeFlushed(syncType)
  end
  print("-->> syncType:", syncType)
  g_NetConnectMgr:showLoadingLayer()
  netsend.login.EnterRole(g_LocalPlayer.m_RoleId, syncType, deviceName)
end
function DataMgr:_EnterGameWithRoleId(roleId)
  if roleId == nil then
    roleId = getConfigByName("lastChoosedRoleId")
  end
  local roleList = g_ServerData.m_ServerRoleList
  if roleId == nil then
    local curZS = 0
    local curLV = 0
    if roleList and #roleList > 0 then
      for i, roleInfo in ipairs(roleList) do
        local zs = roleInfo.i_zs or 0
        local lv = roleInfo.i_lv or 0
        if roleId == nil or curZS < zs or zs == curZS and curLV < lv then
          roleId = roleInfo.i_roleid
          curZS = zs
          curLV = lv
        end
      end
    end
  end
  local player
  if roleId ~= nil and roleList and #roleList > 0 then
    for i, roleInfo in ipairs(roleList) do
      if roleId == roleInfo.i_roleid then
        player = self:_createLocalPlayer(roleInfo.i_roleid, roleInfo.i_rtype, roleInfo.s_name, true)
        break
      end
    end
  end
  if player == nil and #roleList > 0 then
    local roleInfo = roleList[1]
    player = self:_createLocalPlayer(roleInfo.i_roleid, roleInfo.i_rtype, roleInfo.s_name, true)
  end
  if player then
    self:_EnterLocalPlayer()
    setLastLoginServerId(g_ServerData.m_ChoosedLoginServerId)
    setConfigData("lastChoosedRoleId", player:getPlayerId(), true)
  else
    ShowLoginView()
    device.showAlert("登录失败", "获取角色信息错误，请稍候再试", {"确定"}, nil)
  end
end
function DataMgr:EnterGameWithRoleId(roleId)
  print("---->>> EnterGameWithRoleId:", roleId, g_NetConnectMgr:IsConnectGameServer())
  if g_NetConnectMgr:IsConnectGameServer() then
    print("---->>> EnterGameWithRoleId-1")
    self:_EnterGameWithRoleId(roleId)
  else
    print("---->>> EnterGameWithRoleId-2")
    self.m_LoginToRoleIdForReConnectServer = roleId
    g_NetConnectMgr:ConnectServerAndLogin()
  end
end
function DataMgr:EnterGameWithCreateRole(roleType, name, heroindex, rdTimes, edFlag)
  self.m_isNewRole = true
  print("---->>> EnterGameWithCreateRole:", roleId, name, heroindex, g_NetConnectMgr:IsConnectGameServer())
  if g_NetConnectMgr:IsConnectGameServer() then
    print("---->>> EnterGameWithCreateRole-1")
    g_NetConnectMgr:ConnectSvrAndCreatRole(roleType, name, heroindex, rdTimes, edFlag)
  else
    print("---->>> EnterGameWithCreateRole-2")
    self.m_CreateRoleType = roleType
    self.m_CreateRoleName = name
    self.m_CreateRoleHeroIdx = heroindex
    self.m_CreateRoleRandomTimes = rdTimes
    self.m_CreateRoleEditFlag = edFlag
    self.m_CreateRoleIdForReConnectServer = true
    g_NetConnectMgr:ConnectServerAndLogin()
  end
end
function DataMgr:setServerTime(svrtime)
  self.m_ServerTime = svrtime
  self.m_LocalTime = cc.net.SocketTCP.getTime()
  SendMessage(MsgID_ServerTime, svrtime)
end
function DataMgr:getServerTime()
  local currTime = cc.net.SocketTCP.getTime()
  local dt = currTime - self.m_LocalTime
  return self.m_ServerTime + dt
end
function DataMgr:getIsSendFinished()
  return self.m_IsSendFinished
end
function DataMgr:setIsSendFinished(flag)
  self.m_IsSendFinished = flag
end
function DataMgr:OnMessage(msgSID, ...)
  printLog("DataMgr", "OnMessage:" .. tostring(msgSID))
  local arg = {
    ...
  }
  if msgSID == MsgID_EnterBackground then
    print("========>>>DataMgr:玩家退后台")
    self.m_IsBackGroud = true
    if g_LocalPlayer then
      g_LocalPlayer:SaveArchive()
    end
    soundManager.OnEnterBackroundFlush()
  elseif msgSID == MsgID_EnterForeground then
    print("========>>>DataMgr:玩家回前台")
    self.m_IsBackGroud = false
    if self.isPaying ~= true then
      soundManager.OnEnterForeroundFlush()
    end
  elseif msgSID == MSGID_Channel_LogoutSucceed then
    print("---> 渠道登出")
    self:returnToLoginView()
  elseif msgSID == MSGID_Channel_GuestRegistered then
    print("---> 游客注册为正式帐号")
    device.showAlert("帐号发生变动", "帐号信息发生变动,需要重新登录才能正常游戏。", {"确定"}, function()
      self:returnToLoginView()
    end)
  elseif msgSID == MsgID_Key_Back then
    print("---> 安卓返回键")
    g_ChannelMgr:requestExitGame(function(result)
      if result == 1 then
        if g_MissionMgr and g_MissionMgr.delGuideAni then
          g_MissionMgr:delGuideAni()
        end
        local director = CCDirector:sharedDirector()
        director:endToLua()
      end
    end)
  elseif msgSID == MsgID_HeroUpdate then
    print("DataMgr:MsgID_HeroUpdate")
    local playerId = arg[1].pid
    local heroId = arg[1].heroId
    local player = g_DataMgr:getPlayer(playerId)
    if playerId ~= g_LocalPlayer:getPlayerId() then
      print("playerId ~= g_LocalPlayer:getPlayerId()", playerId, g_LocalPlayer:getPlayerId())
      return
    end
    if player == nil or heroId ~= 1 then
      print("player == nil or heroId ~= 1:", player, heroId)
      return
    end
    local lv = arg[1].pro[PROPERTY_ROLELEVEL]
    local zs = arg[1].pro[PROPERTY_ZHUANSHENG]
    print("zs, lv", zs, lv)
    if lv ~= nil or zs ~= nil then
      local d = g_ServerData.m_ServerRoleList
      if d then
        for i, roleInfo in ipairs(d) do
          print("-->> roleInfo.i_roleid == playerId:", roleInfo.i_roleid, playerId)
          if roleInfo.i_roleid == playerId then
            if zs ~= nil then
              roleInfo.i_zs = zs
              print("\t\t changed zs")
            end
            if lv ~= nil then
              roleInfo.i_lv = lv
              print("\t\t changed lv")
            end
          end
        end
      end
    end
  end
end
function DataMgr:requestLogout()
  g_ChannelMgr:Logout()
  self:returnToLoginView()
end
function DataMgr:returnToLoginView()
  printLog("DataMgr", "returnToLoginView")
  if g_Click_Skill_View ~= nil then
    g_Click_Skill_View:removeFromParentAndCleanup(true)
    g_Click_Skill_View = nil
  end
  if g_Click_Item_View ~= nil then
    g_Click_Item_View:removeFromParentAndCleanup(true)
    g_Click_Item_View = nil
  end
  if g_Click_Attr_View ~= nil then
    g_Click_Attr_View:removeFromParentAndCleanup(true)
    g_Click_Attr_View = nil
  end
  if g_Click_MONSTER_Head_View ~= nil then
    g_Click_MONSTER_Head_View:removeFromParentAndCleanup(true)
    g_Click_MONSTER_Head_View = nil
  end
  if g_Click_PET_Head_View ~= nil then
    g_Click_PET_Head_View:removeFromParentAndCleanup(true)
    g_Click_PET_Head_View = nil
  end
  self:resetAllData()
  scheduler.performWithDelayGlobal(function()
    ShowSelectSerView()
  end, 0.1)
end
function DataMgr:resetAllData()
  g_ChannelMgr:hideToolBar()
  if g_SettingDlg_SysSetting then
    g_SettingDlg_SysSetting:SaveData()
  end
  if g_LocalPlayer then
    g_LocalPlayer:SaveArchive()
  end
  if g_MessageMgr then
    g_MessageMgr:SaveMsgToLocal()
  end
  SendMessage(MsgID_LoginOut)
  self.m_IsInGame = false
  self.m_ServerTime = 0
  self.m_LocalTime = 0
  self.m_LoginStatus = 0
  self.m_IsSendFinished = false
  g_NetConnectMgr:CloseConnect()
  gamereset.resetAll()
end
function DataMgr:IsInGame()
  return self.m_IsInGame
end
function DataMgr:DetectAcceleratorUpdate(dt)
  if self.m_DetectAcceleratorServerTime > 0 and 0 < self.m_DetectAcceleratorTimer then
    self.m_DetectAcceleratorTimer = self.m_DetectAcceleratorTimer - dt
    if 0 >= self.m_DetectAcceleratorTimer then
      netsend.netbaseptc.flushServerTime()
      self.m_IsWaittingServerTime = true
      print(" DetectAccelerator--->> 请求刷新服务器时间")
    end
  end
end
function DataMgr:setDetectAcceleratorServerTime(svrTime)
  if svrTime > 0 and self.m_IsWaittingServerTime == true then
    print(" DetectAccelerator self.m_DetectAcceleratorServerTime, svrTime", self.m_DetectAcceleratorServerTime, svrTime, svrTime - self.m_DetectAcceleratorServerTime)
    local dTime = math.abs(svrTime - self.m_DetectAcceleratorServerTime)
    if dTime > self.m_DetectAcceleratorTime + 4 then
      print(" DetectAccelerator------------>> 加速器启动了")
    end
  end
  self.m_DetectAcceleratorServerTime = svrTime
  if svrTime > 0 then
    self.m_DetectAcceleratorTimer = self.m_DetectAcceleratorTime
    self.m_IsWaittingServerTime = false
  end
end
function DataMgr:SyncPlayerTypeFlushed(t)
  self.m_SyncPlayerType = tonumber(t)
  setConfigData("SyncPlayerType", self.m_SyncPlayerType)
  SendMessage(MsgID_MapScene_SyncPlayerTypeChaned, self.m_SyncPlayerType)
end
function DataMgr:getCacheServerData()
  return g_ServerData
end
function DataMgr:receiveFinishEventData(data)
  print("receiveFinishEventData")
  dump(data, "data")
  data = data or {}
  local dData = {}
  local notFinishedNum = 0
  for i, v in ipairs(data) do
    local id = checkint(v.id)
    local cnt = v.cnt
    local limit = v.limit
    local info = data_FinishCnt[id]
    if info ~= nil and id ~= nil and cnt ~= nil and limit ~= nil then
      dData[#dData + 1] = {
        id = id,
        name = info.Name,
        cnt = cnt,
        limit = limit,
        order = info.Order,
        isComplete = cnt >= limit
      }
      if cnt < limit then
        notFinishedNum = notFinishedNum + 1
      end
    end
  end
  table.sort(dData, function(d1, d2)
    if d1 == nil then
      return true
    end
    if d2 == nil then
      return false
    end
    if d1.isComplete == true and d2.isComplete == false then
      return false
    elseif d1.isComplete == false and d2.isComplete == true then
      return true
    end
    local order1 = d1.order
    local order2 = d2.order
    return order1 < order2
  end)
  self.m_FinishedEventData = dData
  self.m_NotFinishedEventNum = notFinishedNum
  SendMessage(MsgID_Activity_FinishCountUpdate)
end
function DataMgr:getFinishEventData()
  return self.m_FinishedEventData, self.m_NotFinishedEventNum
end
function DataMgr:Clear()
  self.m_isNewRole = false
  self.isPaying = false
  self:ClearAllPlayer()
  self:RemoveAllMessageListener()
  if self.m_updateHandler then
    scheduler.unscheduleGlobal(self.m_updateHandler)
    self.m_updateHandler = nil
  end
end
g_DataMgr = DataMgr.new()
gamereset.registerResetFunc(function(reload)
  if reload ~= true then
    if g_DataMgr then
      g_DataMgr:Clear()
      g_DataMgr = nil
    end
    g_DataMgr = DataMgr.new()
  elseif g_DataMgr and g_DataMgr.m_EnterRoleInfo ~= nil then
    local roleid = g_DataMgr.m_EnterRoleInfo[1]
    local rtype = g_DataMgr.m_EnterRoleInfo[2]
    local name = g_DataMgr.m_EnterRoleInfo[3]
    g_DataMgr:ClearAllPlayer()
    g_DataMgr:_createLocalPlayer(roleid, rtype, name, true)
  end
end)
