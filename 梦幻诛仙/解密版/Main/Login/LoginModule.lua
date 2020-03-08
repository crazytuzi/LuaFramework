local Lplus = require("Lplus")
local ModuleBase = require("Main.module.ModuleBase")
local LoginModule = Lplus.Extend(ModuleBase, "LoginModule")
require("Main.module.ModuleId")
local ECGame = Lplus.ForwardDeclare("ECGame")
local LoginUtility = require("Main.Login.LoginUtility")
local CRoleOffline = require("netio.protocol.mzm.gsp.CRoleOffline")
local ServerListMgr = require("Main.Login.ServerListMgr")
local LoginHistoryMgr = require("Main.Login.LoginHistoryMgr")
local LoginPreloadMgr = require("Main.Login.LoginPreloadMgr")
local LoginUIMgr = require("Main.Login.LoginUIMgr")
local LoginFailureMgr = require("Main.Login.LoginFailureMgr")
local ECMSDK = require("ProxySDK.ECMSDK")
local ECUniSDK = require("ProxySDK.ECUniSDK")
local netData = require("netio.netdata")
local GSPConst = require("netio.protocol.mzm.gsp.Const")
local CrossServerLoginMgr = require("Main.Login.CrossServerLoginMgr")
local LoadingMgr = require("Main.Common.LoadingMgr")
local FreeFlowMgr = require("Main.FreeFlow.FreeFlowMgr")
local DeviceUtility = require("Utility.DeviceUtility")
local Octets = require("netio.Octets")
local def = LoginModule.define
local NOT_SET = -1
def.const("table").PreloadResType = LoginPreloadMgr.PreloadResType
def.const("table").EnterWorldType = _G.EnterWorldType
def.const("table").LeaveWorldReason = _G.LeaveWorldReason
def.const("table").CResult = {
  SUCCESS = 0,
  ROLE_ARE_DELETING = 1,
  ROLE_NOT_EXIST = 2,
  ROLE_ARE_BANNED = 3
}
def.field("string").userName = ""
def.field("string").password = ""
def.field("string").serverIp = ""
def.field("string").serverPort = ""
def.field("table").selectedServerCfg = nil
def.field("number").selectedServerNo = 0
def.field("table").roleList = nil
def.field("userdata").lastLoginRoleId = nil
def.field("table").serverList = nil
def.field("table").m_loginParam = nil
def.field("number").m_loginPlatform = 0
def.const("number").AUTO_CONNECT_MAX_TIME_OUT_TIMES = 8
def.field("number").autoConnectTimeoutTimes = 0
def.const("table").LoginTarget = {
  None = 0,
  Server = 1,
  Role = 2
}
def.field("number").loginTarget = 0
def.field("boolean").isEnteredWorld = false
def.field("boolean").isReconnecting = false
def.field("boolean").isLoginLoading = false
def.field("boolean").connecting = false
def.field("boolean").useAutoConnect = true
def.field("number").autoConnectCount = 0
def.field("boolean").noAuthcLogin = false
def.field("boolean").isFreeFlowLogin = false
def.field("boolean").m_forceFreeFlow = false
def.field(LoginHistoryMgr).historyMgr = nil
def.field(LoginPreloadMgr).preloadMgr = nil
local instance
def.static("=>", LoginModule).Instance = function()
  if instance == nil then
    instance = LoginModule()
    instance.m_moduleId = ModuleId.LOGIN
  end
  return instance
end
def.override().Init = function(self)
  ModuleBase.Init(self)
  self:InitLoginPlatform()
  gmodule.network.connectLinkHandler = LoginModule.OnConnectLink
  gmodule.network.connectLostHandler = LoginModule.OnConnectLost
  gmodule.network.connectErrorHandler = LoginModule.OnConnectError
  gmodule.network.netErrorHandler = LoginModule.OnNetError
  gmodule.network.authcOkHandler = LoginModule.OnAuthcOk
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SGetRoleList", LoginModule.OnSGetRoleList)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SLoginRole", LoginModule._OnSLoginRole)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SCreateRole", LoginModule._OnSCreateRole)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SUserForbid", LoginModule._OnSUserForbid)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SDeleteRoleRes", LoginModule._OnSDeleteRoleRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SUnDeleteRoleRes", LoginModule._OnSUnDeleteRoleRes)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SAccountNumLimit", LoginModule._OnSAccountNumLimit)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SRoleOffline", LoginModule._OnSRoleOffline)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SNormalResult", LoginModule._OnSNormalResult)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.SRoleInCrossServerRes", LoginModule._OnSRoleInCrossServerRes)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SUCCESS, LoginModule._OnLoginAccountSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_LOADING_FINISHED, LoginModule._OnLoadingFinished)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_LEVEL_UP, LoginModule._OnHeroRoleInfoChange)
  Event.RegisterEvent(ModuleId.HERO, gmodule.notifyId.Hero.HERO_PROP_INIT, LoginModule._OnHeroRoleInfoChange)
  Event.RegisterEvent(ModuleId.MULTIOCCUPATION, gmodule.notifyId.MultiOccupation.OccupationChange, LoginModule._OnOccupationChange)
  require("Main.Login.LoginUIMgr").Instance():Init()
  require("Main.Login.ActivateMgr").Instance():Init()
  require("Main.Login.LoginQueueMgr").Instance():Init()
  LoginFailureMgr.Instance():Init()
  FreeFlowMgr.Instance():Init()
  self.m_forceFreeFlow = FreeFlowMgr.Instance():IsDebugOpen()
  self.historyMgr = LoginHistoryMgr.Instance()
  self.preloadMgr = LoginPreloadMgr.Instance()
end
def.method().InitLoginPlatform = function(self)
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  local key = "LOGIN_PLATFORM"
  local loginPlatform = _G.platform
  if LuaPlayerPrefs.HasGlobalKey(key) then
    loginPlatform = LuaPlayerPrefs.GetGlobalInt("LOGIN_PLATFORM")
  end
  self.m_loginPlatform = loginPlatform
end
def.method().Start = function(self)
  self:ShowLoginEntryPoint()
end
def.method().ShowLoginEntryPoint = function(self)
  if platform == 0 or ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.MSDK then
    LoginUIMgr.Instance():ShowInputAccountUI()
  else
    LoginUIMgr.Instance():ShowLoginMainUI()
  end
end
def.method().SDKSetUpUser = function(self)
  local sdkType = ClientCfg.GetSDKType()
  if sdkType == ClientCfg.SDKTYPE.MSDK then
  elseif sdkType == ClientCfg.SDKTYPE.UNISDK and not ECUniSDK.Instance():IsLogin() then
    ECUniSDK.Instance():Login({})
  end
end
def.method("=>", "boolean").SDKLoginDone = function(self)
  local sdkType = ClientCfg.GetSDKType()
  if sdkType == ClientCfg.SDKTYPE.MSDK then
    return true
  elseif sdkType == ClientCfg.SDKTYPE.UNISDK and not ECUniSDK.Instance():IsLogin() then
    ECUniSDK.Instance():Login({})
    return false
  end
  return true
end
def.method().SDKLogOut = function(self)
  local sdkType = ClientCfg.GetSDKType()
  if sdkType == ClientCfg.SDKTYPE.MSDK then
    LoginUtility.StopAuroraSdk()
    ECMSDK.UserLogOut()
  elseif sdkType == ClientCfg.SDKTYPE.UNISDK then
    ECUniSDK.Instance():Logout({})
  end
end
def.method("dynamic", "dynamic").SetServerInfo = function(self, address, port)
  self.serverIp = address or self.serverIp
  self.serverPort = port or self.serverPort
  local numberPort = tonumber(port)
  if address and numberPort then
    ECGame.Instance():SetServerInfo(address, numberPort)
    gmodule.network.setServerInfo(address, port)
  end
end
def.method("dynamic", "dynamic").SetAccountInfo = function(self, user, pwd)
  self.userName = user or self.userName
  self.password = pwd or self.password
end
def.method("=>", "boolean").LoginServer = function(self)
  self.loginTarget = LoginModule.LoginTarget.Server
  return self:Login()
end
def.method("=>", "boolean").LoginServerAndRole = function(self)
  self.loginTarget = LoginModule.LoginTarget.Role
  return self:Login()
end
def.method().ResetConnect = function(self)
  self.isReconnecting = false
  self.connecting = false
  self.isFreeFlowLogin = false
end
def.method().ReLogin = function(self)
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(0)
  if self.isEnteredWorld then
    self:LeaveWorld(LoginModule.LeaveWorldReason.CHANGE_ACCOUNT)
  else
    self:RoleOffline(CRoleOffline.LINK_BREAK)
  end
  gmodule.network.disConnect()
  self:ResetConnect()
  self:SDKLogOut()
  require("Main.UpdateNotice.UpdateNoticeModule").Instance():Clear()
  ServerListMgr.Instance():Clear()
  CrossServerLoginMgr.Instance():Clear()
  FreeFlowMgr.Instance():Clear()
  FreeFlowMgr.Instance():ResetFailures()
  self.selectedServerCfg = nil
  self.selectedServerNo = 0
  self.roleList = nil
  self.lastLoginRoleId = nil
  self:ShowLoginEntryPoint()
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RE_LOGIN, nil)
end
def.method().Back2Login = function(self)
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(0)
  if self.isEnteredWorld then
    self:LeaveWorld(LoginModule.LeaveWorldReason.BACK2LOGIN)
  else
    self:RoleOffline(CRoleOffline.LINK_BREAK)
  end
  gmodule.network.disConnect()
  self:ResetConnect()
  CrossServerLoginMgr.Instance():Clear()
  FreeFlowMgr.Instance():Clear()
  self.selectedServerCfg = nil
  self.roleList = nil
  self.lastLoginRoleId = nil
  LoginUIMgr.Instance():ShowLoginMainUI()
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.BACK_TO_LOGIN, nil)
end
def.method().Back2SelectRole = function(self)
  if not gmodule.network.isconnected() then
    return
  end
  self:RoleOffline(CRoleOffline.CHANGE_ROLE)
end
def.method("=>", "boolean").IsRoleListEmpty = function(self)
  return self.roleList == nil or #self.roleList == 0
end
def.method("string", "number", "number", "string").CreateRole = function(self, name, occupation, gender, inviteCode)
  local CreateRoleArg = require("netio.protocol.mzm.gsp.CreateRoleArg").new(name, occupation, gender, 1, require("netio.Octets").rawFromString(inviteCode))
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.CCreateRole").new(CreateRoleArg))
end
def.method("userdata").DeleteRole = function(self, roleid)
  local roleInfo = self:GetRoleInfo(roleid)
  if roleInfo == nil then
    warn(string.format("no roleInfo found for roleId = %s", tostring(roleid)))
    return
  end
  local roleLevel = roleInfo.basic.level
  local forbidMinLevel = LoginUtility.GetForbidDeleteRoleMinLevel()
  if roleLevel >= forbidMinLevel then
    local text = string.format(textRes.Login[62], forbidMinLevel)
    Toast(text)
    return
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.CDeleteRoleReq").new(roleid))
end
def.method("userdata").CancelDeleteRole = function(self, roleid)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.CUnDeleteRoleReq").new(roleid))
end
def.method("userdata", "=>", "number").LoginRole = function(self, roleid)
  local roleInfo = self:GetRoleInfo(roleid)
  if roleInfo == nil then
    Toast(textRes.Login.SLoginRole[1])
    return LoginModule.CResult.ROLE_NOT_EXIST
  end
  if self:IsRoleDeleting(roleid) then
    Toast(textRes.Login[35])
    return LoginModule.CResult.ROLE_ARE_DELETING
  end
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.CLoginRole").new(roleid))
  return LoginModule.CResult.SUCCESS
end
def.method().ReLoginRole = function(self)
  local roleid = self.lastLoginRoleId
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.CReConnect").new(roleid))
end
def.method().EnterWorld = function(self)
  require("GUI.WaitingTip").HideTip()
  local enterType = LoginModule.EnterWorldType.NORMAL
  if self.isReconnecting then
    enterType = LoginModule.EnterWorldType.RECONNECT
    require("GUI.ECGUIMan").Instance():OnSuccessReconnected()
  end
  require("Main.ECGame").Instance():SetGameState(_G.GameState.GameWorld)
  netData.setGameStatus(netData.GAME_STATUS_ENTERGAME)
  self.isEnteredWorld = true
  self.isReconnecting = false
  self.autoConnectTimeoutTimes = 0
  ECMSDK.SetGSDKEvent(6, true, "success")
  TraceHelper.trace("EnterGame")
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, {enterType = enterType})
end
def.method("number").LeaveWorld = function(self, reason)
  if not self.isEnteredWorld then
    return
  end
  local function destroyUIs()
    if reason == LoginModule.LeaveWorldReason.RECONNECT then
      require("GUI.ECGUIMan").Instance():DestroyUIForReconnect()
    else
      require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(0)
    end
  end
  destroyUIs()
  self.isEnteredWorld = false
  if reason == LoginModule.LeaveWorldReason.CHANGE_ACCOUNT then
    self:RoleOffline(CRoleOffline.QUIT_GAME)
  end
  if reason == LoginModule.LeaveWorldReason.RECONNECT then
    self.isReconnecting = true
  else
    require("Main.ECGame").Instance():SetGameState(_G.GameState.LeavingGameWorld)
  end
  _G.leaveWorldReason = reason
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, {reason = reason})
  gmodule.network.ClearProtocols()
  destroyUIs()
end
def.method().Logout = function(self)
  self:RoleOffline(CRoleOffline.QUIT_GAME)
  self:SaveLoginInfo()
end
def.method().C2S_GetRoleList = function(self)
  require("Main.FeatureOpenList.FeatureOpenListModule").Instance():OnReset()
  gmodule.network.checkRoleInfoOk()
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.CGetRoleList").new())
end
def.method("number").RoleOffline = function(self, reason)
  warn("self:RoleOffline(" .. reason .. ")")
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.CRoleOffline").new(reason))
end
def.method("=>", "table").GetRoleList = function(self)
  return self.roleList
end
def.method("=>", "table").GetCachedRoleList = function(self)
  return LoginUtility.GetRoleListCfg(self.userName, self.selectedServerNo)
end
def.method("userdata", "=>", "table").GetRoleInfo = function(self, roleid)
  if self.roleList == nil then
    return nil
  end
  local info
  for i, roleInfo in ipairs(self.roleList) do
    if roleInfo.roleid == roleid then
      info = roleInfo
      break
    end
  end
  return info
end
def.method("userdata", "=>", "boolean").IsRoleBanned = function(self, roleId)
  local roleInfo = self:GetRoleInfo(roleId)
  if roleInfo == nil then
    return false
  end
  if roleInfo.expiretime:gt(0) then
    return true
  else
    return false
  end
end
def.method("userdata", "=>", "boolean").IsRoleDeleting = function(self, roleId)
  local roleInfo = self:GetRoleInfo(roleId)
  if roleInfo == nil then
    return false
  end
  if roleInfo.delEndtime > 0 then
    return true
  else
    return false
  end
end
def.method().SaveLoginInfo = function(self)
  if self.selectedServerNo == 0 then
    return
  end
  self.historyMgr:SaveLoginHistory(self.userName, self.selectedServerNo, self.lastLoginRoleId)
end
def.method("=>", "table").GetLastLoginRole = function(self)
  if self.roleList == nil then
    local serverId = self.selectedServerNo
    if serverId == 0 then
      return nil
    end
    return LoginUtility.GetServerLastLoginRoleCfg(self.userName, serverId)
  end
  for i, role in ipairs(self.roleList) do
    if role.roleid == self.lastLoginRoleId then
      return role
    end
  end
  return self.roleList[1]
end
def.static("table", "table")._OnLoginAccountSuccess = function()
  local self = instance
  self:GetFreeFlowAddreesAsync(nil)
  local gameState = ECGame.Instance():GetGameState()
  if gameState == _G.GameState.None or gameState == _G.GameState.LoginAccount or ClientCfg.GetSDKType() == ClientCfg.SDKTYPE.UNISDK then
    self:SetAccountInfo(ECGame.Instance().m_UserName, ECGame.Instance().m_Password)
    ServerListMgr.Instance():RefreshServerList()
    instance.historyMgr:LoadCurUserLoginHistory()
    if gameState == _G.GameState.None or gameState == _G.GameState.LoginAccount then
      LoginUIMgr.Instance():ShowLoginMainUI()
    end
  end
end
def.static("table").OnSGetRoleList = function(p)
  netData.setGameStatus(netData.GAME_STATUS_ROLEINFOOK)
  LoginFailureMgr.Instance():ResetFailures()
  LoginUtility.StopAuroraSdk()
  local self = instance
  if p.roles == nil or #p.roles < 1 then
    self.roleList = {}
  else
    self.roleList = self:_WrapSRoleList(p)
  end
  self:_OnLoginServerSuccess()
end
def.method()._OnLoginServerSuccess = function(self)
  self:SaveLoginInfo()
  if self:IsRoleListEmpty() then
    if self.loginTarget == LoginModule.LoginTarget.Role then
      warn("CACHED_ROLE_NOT_EXIST")
      Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.CACHED_ROLE_NOT_EXIST, nil)
    end
    LoginUIMgr.Instance():ShowCreateRoleUI()
  elseif self.loginTarget == LoginModule.LoginTarget.Server then
    LoginUIMgr.Instance():ShowSelectRoleUI()
  end
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SERVER_SUCCESS, nil)
end
def.method("table", "=>", "table")._WrapSRoleList = function(self, p)
  local cachedRoleList = self:GetCachedRoleList() or {}
  local roleidOrderMap = {}
  for i, v in ipairs(cachedRoleList) do
    roleidOrderMap[tostring(v.roleid)] = i
  end
  local roleList = p.roles
  table.sort(roleList, function(left, right)
    local leftOrder = roleidOrderMap[tostring(left.roleid)] or math.huge
    local rightOrder = roleidOrderMap[tostring(right.roleid)] or math.huge
    return leftOrder <= rightOrder
  end)
  self.lastLoginRoleId = roleList[1].roleid
  for i, role in ipairs(roleList) do
    role.ctime = os.time()
    local roleModels = {}
    for k, v in pairs(p.roleModels) do
      roleModels[tostring(k)] = v
    end
    role.modelInfo = roleModels[tostring(role.roleid)]
  end
  return roleList
end
def.static("table", "table")._OnLoadingFinished = function(params, context)
  local self = instance
  LoginUtility.DestroyLoginBackground()
  self:EnterWorld()
  local SystemSettingModule = require("Main.SystemSetting.SystemSettingModule")
  local setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.FPS_HIGH)
  if setting.isEnabled then
    ECGame.Instance():SetHighQualityFrame(3)
    return
  end
  setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.FPS_MEDIUM)
  if setting.isEnabled then
    ECGame.Instance():SetHighQualityFrame(2)
    return
  end
  setting = SystemSettingModule.Instance():GetSetting(SystemSettingModule.SystemSetting.FPS_LOW)
  if setting.isEnabled then
    ECGame.Instance():SetHighQualityFrame(1)
    return
  end
end
def.static("table", "table")._OnHeroRoleInfoChange = function(params, context)
  instance:SaveLoginInfo()
end
def.static("table", "table")._OnOccupationChange = function(params, context)
  local heroProp = _G.GetHeroProp()
  if heroProp == nil then
    return
  end
  local occupation = params.newid or 0
  local gender = heroProp.gender
  require("Main.Login.SwitchOccupationLoginMgr").Instance():ReconnectAs(occupation, gender)
end
def.static("table")._OnSUserForbid = function(p)
  printInfo(string.format("[SYS] You are forbidden, expire_time = %s, reason: %s", tostring(p.expire_time), p.reason))
  gmodule.network.disConnect()
  instance:ResetConnect()
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
  LoginUIMgr.Instance():ShowUserBeBannedPrompt(p.expire_time, p.reason)
end
def.static("table")._OnSCreateRole = function(p)
  print("*LUA* SCreateRole")
  local screateRole = require("netio.protocol.mzm.gsp.SCreateRole")
  if p.result == screateRole.ERR_SUCCESS then
    printInfo("create role success")
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.CREATE_ROLE_SUCCESS, nil)
    local self = instance
    self.roleList = self.roleList or {}
    table.insert(self.roleList, p.roleinfo)
    self:LoginRole(p.roleinfo.roleid)
    TraceHelper.trace("RoleCreation")
  else
    print("create role error:", p.result)
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
    if p.result == screateRole.ERR_ACCOUNT_NUM_LIMIT then
    else
      Toast(textRes.Login.SCreateRole[p.result] or "unhandled error: " .. p.result)
    end
  end
end
def.static("table")._OnSDeleteRoleRes = function(p)
  local role = instance:GetRoleInfo(p.roleId)
  role.delEndtime = p.endTime
  role.ctime = os.time()
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ROLE_INFO_UPDATE, {
    p.roleId
  })
end
def.static("table")._OnSUnDeleteRoleRes = function(p)
  local role = instance:GetRoleInfo(p.roleId)
  role.delEndtime = 0
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ROLE_INFO_UPDATE, {
    p.roleId
  })
end
def.static("table")._OnSAccountNumLimit = function(p)
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
end
def.static("table")._OnSRoleOffline = function(p)
  local self = instance
  require("GUI.ECGUIMan").Instance():DestroyUIAtLevel(0)
  self:LeaveWorld(LoginModule.LeaveWorldReason.CHANGE_ROLE)
  instance.loginTarget = LoginModule.LoginTarget.Server
  self:C2S_GetRoleList()
  LoginUtility.PlayLoginBGM()
end
def.static("table")._OnSNormalResult = function(p)
  local text = textRes.Login.SNormalResult[p.res] or "unhandled result: " .. p.res
  Toast(text)
end
def.static("table")._OnSRoleInCrossServerRes = function(p)
  local crossServerCxt = {}
  crossServerCxt.roleid = p.roleid
  crossServerCxt.zoneid = p.zoneid
  crossServerCxt.token = p.token
  warn("crossServerCxt.token", tostring(crossServerCxt.token))
  CrossServerLoginMgr.Instance():SetCrossServerContext(crossServerCxt)
  local hostLoginToken = gmodule.network.getLoginToken()
  local hostServerCxt = {}
  hostServerCxt.zoneid = instance.selectedServerNo
  hostServerCxt.roleid = p.roleid
  hostServerCxt.token = hostLoginToken
  warn("hostLoginToken", hostLoginToken)
  CrossServerLoginMgr.Instance():SetHostServerContext(hostServerCxt)
end
def.static("table")._OnSLoginRole = function(p)
  if p.result == require("netio.protocol.mzm.gsp.SLoginRole").ERR_LOGIN_SUCCESS then
    netData.setGameStatus(netData.GAME_STATUS_ROLEINFOOK)
    instance.lastLoginRoleId = p.roleid
    instance:SaveLoginInfo()
    instance.autoConnectCount = 0
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_SUCCESS, nil)
    require("Main.Hero.HeroModule").Instance():SetMyRoleId(p.roleid)
    instance.preloadMgr:PreloadRes()
    gmodule.moduleMgr:GetModule(ModuleId.MAP):EnterWorld()
  else
    if p.result == p.class.ERR_LOGIN_ROLE_FORBIDE then
      local reason = _G.GetStringFromOcts(p.reason)
      LoginUIMgr.Instance():ShowRoleBeBannedPrompt(p.roleid, p.expire_time, reason)
    elseif p.result == p.class.ERR_LOGIN_USER_FORBIDE then
      local reason = _G.GetStringFromOcts(p.reason)
      LoginUIMgr.Instance():ShowUserBeBannedPrompt(p.expire_time, reason)
    else
      Toast(textRes.Login.SLoginRole[p.result])
    end
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_ROLE_ERROR, nil)
  end
end
def.static("number").OnConnectError = function(errcode)
  warn("OnConnectError:", errcode)
  CrossServerLoginMgr.Instance():Clear()
  if instance:IsFreeFlowLogin() then
    FreeFlowMgr.Instance():RecordFreeFlowFailure()
  end
  instance:CheckAutoConnect()
end
def.static("number", "string").OnNetError = function(errcode, errorInfo)
  warn("OnNetError:", errcode)
  local self = instance
  gmodule.network.disConnect()
  if errcode == GSPConst.ERR_CROSS_SERVER_FORCE_KICKOUT and CrossServerLoginMgr.Instance():Login() then
    return
  elseif errcode == GSPConst.ERR_RETURN_ORIGINAL_SERVER_FORCE_KICKOUT and CrossServerLoginMgr.Instance():Logback() then
    return
  end
  self:ResetConnect()
  CrossServerLoginMgr.Instance():Clear()
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
  ECGame.Instance():RequestDirInfo()
  local tipContent = textRes.Login.NetError[errcode]
  if errcode == GSPConst.ERR_BAN_LOGIN then
    tipContent = LoginUtility.ConvertBanLoginErrorInfo(errorInfo)
  end
  if tipContent == nil or tipContent == "" then
    tipContent = textRes.Login.NetError[1]
  end
  self:ShowConnectLostDlg(errcode, tipContent)
  LoginFailureMgr.Instance():RecordLoginFailure()
end
def.static().OnConnectLost = function()
  warn("OnConnectLost", debug.traceback())
  if _G.IsReplayNetIO then
    return
  end
  CrossServerLoginMgr.Instance():Clear()
  instance:CheckAutoConnect()
end
def.static().OnConnectLink = function()
  local self = instance
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.CONNECT_LINK, nil)
end
def.static().OnAuthcOk = function()
  local self = instance
  if self.isReconnecting then
    self:LeaveWorld(LoginModule.LeaveWorldReason.RECONNECT)
    self:ReLoginRole()
  else
    self:C2S_GetRoleList()
  end
  ECGame.Instance():StopRefreshDirTimer()
  FreeFlowMgr.Instance():ResetFailures()
end
def.method().CheckAutoConnect = function(self)
  if not self.isReconnecting then
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
  end
  ECGame.Instance():RequestDirInfo()
  local isServerShutDown = require("Main.Server.ServerModule").Instance():IsServerShutDown()
  local needReconnect = false
  if self:IsInWorld() and not isServerShutDown then
    needReconnect = true
  end
  local function showConnectLost(promoteText)
    self:ResetConnect()
    self:LeaveWorld(LoginModule.LeaveWorldReason.BACK2LOGIN)
    self:ShowConnectLostDlg(nil, promoteText)
  end
  if needReconnect then
    GameUtil.AddGlobalTimer(1, true, function(...)
      if GameUtil.HasGotDirInfo() and self:IsSelectedServerClose() then
        local promoteText = self:GetSelectedServerCloseNotice()
        showConnectLost(promoteText)
      elseif ECGame.Instance():GetGameState() == _G.GameState.GameWorld then
        self:AutoConnect()
      end
    end)
  else
    local promoteText = textRes.Login[102]
    if self:IsSelectedServerClose() then
      promoteText = self:GetSelectedServerCloseNotice()
    elseif isServerShutDown then
      promoteText = textRes.Server[2]
    end
    showConnectLost(promoteText)
  end
  LoginFailureMgr.Instance():RecordLoginFailure()
end
def.method("=>", "boolean").IsSelectedServerClose = function()
  local server = ServerListMgr.Instance():GetSelectedServerCfg()
  if server and (server.state == ServerListMgr.ServerState.Fix or server.closed == "true" or server.closed == true) then
    return true
  end
  return false
end
def.method("=>", "string").GetSelectedServerCloseNotice = function()
  local server = ServerListMgr.Instance():GetSelectedServerCfg()
  local closeNotice = textRes.Login.ConnectError[100]
  if server and server.notice and #server.notice > 0 then
    closeNotice = server.notice
  end
  return closeNotice
end
local dlg
def.method().ShowReconnectDlg = function(self)
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
  local function dlgCallback(i, tag)
    dlg = nil
    if i == 1 then
      self:AutoConnect()
    else
      self:Back2Login()
    end
  end
  if dlg then
    dlg:DestroyPanel()
  end
  dlg = require("GUI.CommonConfirmDlg").ShowConfirmCoundDown(textRes.Login[100], textRes.Login[107], textRes.Login[109], textRes.Login[110], 1, 10, dlgCallback, {m_level = 0})
  self:AutoAdjustDlgDepth(dlg)
end
local dlg
def.method("dynamic", "dynamic").ShowConnectLostDlg = function(self, errcode, promoteText)
  Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.RESET_UI, nil)
  local title = textRes.Login[100]
  if errcode then
    title = title .. string.format(" [%d]", errcode)
  end
  promoteText = promoteText or textRes.Login[102]
  if dlg then
    dlg:DestroyPanel()
  end
  dlg = require("GUI.CommonConfirmDlg").ShowCerternConfirm(title, promoteText, "", function()
    if errcode == 3 then
      require("Main.Login.ui.LoginMainPanel").Instance():HidePanel()
      self:ReLogin()
    elseif ECGame.Instance():GetGameState() ~= _G.GameState.ChooseServer then
      self:Back2Login()
    end
  end, {m_level = 0})
  self:AutoAdjustDlgDepth(dlg)
end
local dlg
def.method("string").ShowConnectErrorDlg = function(self, promoteText)
  if dlg then
    dlg:DestroyPanel()
  end
  dlg = require("GUI.CommonConfirmDlg").ShowCerternConfirm(textRes.Login[100], promoteText, "", function(i, tag)
    if ECGame.Instance():GetGameState() == _G.GameState.GameWorld then
      self:Back2Login()
    end
  end, {id = self})
  self:AutoAdjustDlgDepth(dlg)
end
def.method("table").AutoAdjustDlgDepth = function(self, dlg)
  if dlg == nil then
    return
  end
  local depth = GUIDEPTH.TOPMOST
  if LoadingMgr.Instance():IsLoading() then
    depth = GUIDEPTH.TOPMOST2
  end
  dlg:SetDepth(depth)
end
def.method("=>", "boolean").Login = function(self)
  if LoginFailureMgr.Instance():FrequentlyLoginFailureDetected() then
    return false
  end
  local zoneid = self.selectedServerNo
  local serverCfg = ServerListMgr.Instance():GetServerCfg(zoneid)
  if serverCfg == nil then
    warn(string.format("server cfg is nil for zoneid=%d", zoneid))
    return false
  end
  local loginParam = {}
  loginParam.zoneid = zoneid
  loginParam.address = serverCfg.address
  loginParam.port = tostring(math.random(serverCfg.beginPort, serverCfg.endPort))
  loginParam.userid = self:GetZoneUserName(loginParam.zoneid)
  loginParam.password = self.password
  loginParam.loginType = self:GetConnectLoginType()
  ECGame.Instance():SetUserName(loginParam.userid, loginParam.password, loginParam.address, tonumber(loginParam.port))
  self:LoginEx(loginParam)
  return true
end
def.method("table").SetLoginParam = function(self, loginParam)
  local userid = loginParam.userid
  local password = loginParam.password
  self:SetServerInfo(loginParam.address, loginParam.port)
  gmodule.network.setAccountInfo(userid, password, loginParam.loginType)
  self.m_loginParam = loginParam
end
def.method("table").LoginEx = function(self, loginParam)
  if loginParam then
    self:SetLoginParam(loginParam)
  else
    loginParam = self.m_loginParam
    self:SetServerInfo(loginParam.address, loginParam.port)
  end
  self.connecting = true
  self:GetFreeFlowAddreesAsync(function(sockaddr)
    if not self.connecting then
      return
    end
    if sockaddr then
      self.isFreeFlowLogin = true
      printInfo("isFreeFlowLogin = true")
      self:SetServerInfo(sockaddr.address, sockaddr.port)
    else
      self.isFreeFlowLogin = false
      printInfo("isFreeFlowLogin = false")
    end
    gmodule.network.login()
  end)
end
def.method("function").GetFreeFlowAddreesAsync = function(self, callback)
  if not self:NeedFreeFlow() then
    _G.SafeCallback(callback, nil)
    return
  end
  if FreeFlowMgr.Instance():IsFrequentlyFail() then
    printInfo("FreeFlow is frequently fail, switch to normal address")
    Toast(textRes.Login[65])
    _G.SafeCallback(callback, nil)
    return
  end
  printInfo("RequestFreeFlowInfo ...")
  FreeFlowMgr.Instance():RequestFreeFlowInfo(function(freeFlowInfo)
    printInfo("RequestFreeFlowInfo ... finish with " .. tostring(freeFlowInfo))
    local sockaddr
    if freeFlowInfo and freeFlowInfo.isFree and #freeFlowInfo.sockaddrs > 0 then
      local randomIndex = math.random(#freeFlowInfo.sockaddrs)
      sockaddr = freeFlowInfo.sockaddrs[randomIndex]
      if self.m_loginParam then
        sockaddr.port = self.m_loginParam.port
      end
    end
    _G.SafeCallback(callback, sockaddr)
  end)
end
def.method("=>", "boolean").NeedFreeFlow = function(self)
  if self:IsForceFreeFlow() then
    return true
  end
  if _G.IsOverseasVersion() then
    return false
  end
  if DeviceUtility.IsWIFIConnected() then
    if DeviceUtility.IsNetworkStateFixedVersion() then
      printInfo("IsWIFIConnected = true")
      return false
    else
      printInfo("IsWIFIConnected = ?")
    end
  end
  if not FreeFlowMgr.Instance():IsOpen() then
    return false
  end
  return true
end
def.method("function", "=>", "boolean").GetSelectAddreesAsync = function(self, callback)
  local zoneid = self.selectedServerNo
  return self:GetAddreesAsync(zoneid, callback)
end
def.method("number", "function", "=>", "boolean").GetAddreesAsync = function(self, zoneid, callback)
  local serverCfg = ServerListMgr.Instance():GetServerCfg(zoneid)
  if serverCfg == nil then
    _G.SafeCallback(callback, nil)
    warn(string.format("server cfg is nil for zoneid=%d", zoneid))
    return false
  end
  local address = serverCfg.address
  local port = tostring(math.random(serverCfg.beginPort, serverCfg.endPort))
  local sockaddr = {address = address, port = port}
  local serverCfg = ServerListMgr.Instance():GetServerCfg(zoneid)
  self:GetFreeFlowAddreesAsync(function(free_sockaddr)
    if free_sockaddr then
      sockaddr = free_sockaddr
    end
    _G.SafeCallback(callback, sockaddr)
  end)
  return true
end
def.method("=>", "number").GetSelectedZoneId = function(self)
  return self.selectedServerNo
end
def.method("=>", "number").GetConnectZoneId = function(self)
  local context = CrossServerLoginMgr.Instance():GetCrossServerContext()
  if context then
    return context.zoneid
  else
    return self.selectedServerNo
  end
end
def.method("=>", "table").GetConnectedServerCfg = function(self)
  local zoneid = self:GetConnectZoneId()
  return ServerListMgr.Instance():GetServerCfg(zoneid)
end
def.method("number", "=>", "string").GetZoneUserName = function(self, zoneid)
  local userName = self.userName
  if platform == _G.Platform.win and not string.find(userName, "$", 1, true) then
    userName = userName .. "$shadow"
  end
  userName = userName .. "@" .. zoneid
  return userName
end
def.method("=>", "number").GetConnectLoginType = function(self)
  local loginType = netData.LOGIN_TYPE_SDK
  if self:IsNoAuthcLogin() then
    loginType = netData.LOGIN_TYPE_NO_AUTH
  end
  return loginType
end
def.method().AutoConnect = function(self)
  require("GUI.WaitingTip").ShowTip(textRes.Login[30])
  self.isReconnecting = true
  self.loginTarget = LoginModule.LoginTarget.Role
  self.autoConnectCount = self.autoConnectCount + 1
  if self.autoConnectCount > 3 then
    LoginModule.OnAutoConnectTimeout()
  else
    local delayTime = (self.autoConnectCount - 1) * 3
    GameUtil.AddGlobalTimer(delayTime, true, function()
      self:GetFreeFlowAddreesAsync(function(sockaddr)
        if not self:IsInWorld() then
          return
        end
        if sockaddr == nil then
          sockaddr = self.m_loginParam
          self.isFreeFlowLogin = false
        else
          self.isFreeFlowLogin = true
        end
        self:SetServerInfo(sockaddr.address, sockaddr.port)
        gmodule.network.setCanAuto(true)
        gmodule.network.autoConnect(LoginModule.OnAutoConnectTimeout)
      end)
    end)
  end
end
def.static().OnAutoConnectTimeout = function()
  instance.autoConnectTimeoutTimes = instance.autoConnectTimeoutTimes + 1
  instance.autoConnectCount = 0
  if instance.autoConnectTimeoutTimes > LoginModule.AUTO_CONNECT_MAX_TIME_OUT_TIMES then
    instance.autoConnectTimeoutTimes = 0
    instance:ShowConnectLostDlg(nil, textRes.Login[111])
  else
    instance:ShowReconnectDlg()
  end
end
def.method("=>", "boolean").IsLoadingWorld = function(self)
  return ECGame.Instance():GetGameState() == _G.GameState.LoadingGameWorld
end
def.method("=>", "boolean").IsInWorld = function(self)
  return ECGame.Instance():GetGameState() == _G.GameState.GameWorld
end
def.method("boolean").SetLoginNoAuthc = function(self, noAuthcLogin)
  if self.noAuthcLogin ~= noAuthcLogin then
    self.noAuthcLogin = noAuthcLogin
    Event.DispatchEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_TYPE_CHANGE, nil)
  end
end
def.method("=>", "boolean").IsNoAuthcLogin = function(self)
  return self.noAuthcLogin == true
end
def.method("=>", "boolean").IsFreeFlowLogin = function(self)
  return self.isFreeFlowLogin
end
def.method("=>", "boolean").IsForceFreeFlow = function(self)
  return self.m_forceFreeFlow
end
def.method("boolean").ForceFreeFlow = function(self, isForce)
  self.m_forceFreeFlow = isForce
end
def.method("number").SetLoginPlatform = function(self, platform)
  self.m_loginPlatform = platform
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  LuaPlayerPrefs.SetGlobalInt("LOGIN_PLATFORM", platform)
  LuaPlayerPrefs.Save()
end
def.method("=>", "number").GetLoginPlatform = function(self)
  return self.m_loginPlatform
end
def.method("=>", "boolean").IsFakeLoginPlatform = function(self)
  if ClientCfg.GetSDKType() ~= ClientCfg.SDKTYPE.MSDK then
    return false
  end
  if _G.platform ~= Platform.android then
    return false
  end
  if self.m_loginPlatform == _G.platform then
    return false
  end
  if not DeviceUtility.IsTGP() then
    return false
  end
  return true
end
LoginModule.Commit()
return LoginModule
