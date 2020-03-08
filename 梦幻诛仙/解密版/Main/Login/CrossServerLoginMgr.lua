local Lplus = require("Lplus")
local CrossServerLoginMgr = Lplus.Class("CrossServerLoginMgr")
local LoginUIMgr = require("Main.Login.LoginUIMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local netData = require("netio.netdata")
local ECGame = Lplus.ForwardDeclare("ECGame")
local LoadingMgr = require("Main.Common.LoadingMgr")
local def = CrossServerLoginMgr.define
local PreloadResType = {PROTOCOL = 1, PROTOCOL_FAKE = 2}
def.field("table")._hostServerCxt = nil
def.field("table")._crossServerCxt = nil
local instance
def.static("=>", CrossServerLoginMgr).Instance = function()
  if instance == nil then
    instance = CrossServerLoginMgr()
    instance:Init()
  end
  return instance
end
def.method().Init = function(self)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_SERVER_SUCCESS, CrossServerLoginMgr.OnLoginServerSuccess)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LOGIN_LOADING_FINISHED, CrossServerLoginMgr.OnLoadingFinished)
end
def.method("=>", "boolean").IsCrossingServer = function(self)
  return self._crossServerCxt ~= nil
end
def.method("=>", "boolean").Login = function(self)
  print("start cross server login")
  if self._crossServerCxt == nil then
    warn("Cross server login failed: crossServerCxt is nil!")
    return false
  end
  local loginModule = LoginModule.Instance()
  if loginModule:IsInWorld() then
    loginModule:LeaveWorld(LoginModule.LeaveWorldReason.RECONNECT)
  end
  self:SetLoginInfoFromServerCxt(self._crossServerCxt)
  loginModule:LoginEx(nil)
  return true
end
def.method("=>", "boolean").Logback = function(self)
  self:Clear()
  if not LoginModule.Instance():IsInWorld() then
    return false
  end
  local DELAY_BACK_TIME = 2
  GameUtil.AddGlobalTimer(DELAY_BACK_TIME, true, function(...)
    if LoginModule.Instance():IsInWorld() then
      require("Main.Login.InWorldLoginMgr").Instance():Reconnect(nil)
    end
  end)
  return true
end
local protTimerId
def.method().StartLoading = function(self)
  LoadingMgr.Instance():StartLoading(LoadingMgr.LoadingType.CrossServer, {
    [PreloadResType.PROTOCOL] = 1,
    [PreloadResType.PROTOCOL_FAKE] = 80
  }, nil, nil)
  local progress = 0
  local count = 0
  local function fakeProtoclUpdate(...)
    protTimerId = GameUtil.AddGlobalTimer(0.1, true, function()
      if protTimerId == nil then
        return
      end
      if LoadingMgr.Instance().loadingType ~= LoadingMgr.LoadingType.CrossServer then
        protTimerId = nil
        return
      end
      progress = progress + 0.2
      count = count + 1
      local val = math.log10(1 + progress)
      if val >= 1 then
        val = 1
      end
      LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.PROTOCOL_FAKE, val)
      if val < 1 then
        fakeProtoclUpdate()
      else
        protTimerId = nil
      end
    end)
  end
  fakeProtoclUpdate()
end
def.method("table").SetCrossServerContext = function(self, context)
  self._crossServerCxt = context
  if self._crossServerCxt then
    self._crossServerCxt.loginType = netData.LOGIN_TYPE_CROSSSERVER
  end
end
def.method("table").SetHostServerContext = function(self, context)
  self._hostServerCxt = context
  if self._hostServerCxt then
    self._hostServerCxt.loginType = netData.LOGIN_TYPE_TOKEN
  end
end
def.method("=>", "table").GetCrossServerContext = function(self)
  return self._crossServerCxt
end
def.method("=>", "table").GetHostServerContext = function(self)
  return self._hostServerCxt
end
def.method("table").SetLoginInfoFromServerCxt = function(self, serverCxt)
  local Octets = require("netio.Octets")
  local zoneid = serverCxt.zoneid
  local roleid = serverCxt.roleid
  local password = serverCxt.token
  local loginType = serverCxt.loginType or 3
  if type(password) == "string" then
    password = Octets.rawFromString(password)
  end
  local loginModule = LoginModule.Instance()
  loginModule.lastLoginRoleId = roleid
  loginModule.loginTarget = LoginModule.LoginTarget.Role
  local ServerListMgr = require("Main.Login.ServerListMgr")
  local serverCfg = ServerListMgr.Instance():GetServerCfg(zoneid)
  if serverCfg == nil then
    warn(string.format("server cfg is nil for zoneid=%d", zoneid))
    return
  end
  local sel_zoneid = loginModule:GetSelectedZoneId()
  local userName = loginModule:GetZoneUserName(sel_zoneid)
  userName = Octets.rawFromString(userName)
  local loginParam = {}
  loginParam.zoneid = zoneid
  loginParam.address = serverCfg.address
  loginParam.port = tostring(math.random(serverCfg.beginPort, serverCfg.endPort))
  loginParam.userid = userName
  loginParam.password = password
  loginParam.loginType = loginType
  loginModule:SetLoginParam(loginParam)
  warn("SetLoginInfoFromServerCxt.............", tostring(userName), tostring(password), loginParam.address, loginParam.port, loginType)
end
def.method().Clear = function(self)
  if self._hostServerCxt then
    self:SetLoginInfoFromServerCxt(self._hostServerCxt)
  end
  self._crossServerCxt = nil
  self._hostServerCxt = nil
end
def.static("table", "table").OnLoginServerSuccess = function()
  if not instance:IsCrossingServer() then
    return
  end
  local roleid = instance._crossServerCxt.roleid
  LoginModule.Instance():LoginRole(roleid)
end
def.static("table", "table").OnLoadingFinished = function()
  if not instance:IsCrossingServer() then
    return
  end
  if LoadingMgr.Instance().loadingType == LoadingMgr.LoadingType.CrossServer then
    LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.PROTOCOL, 1)
    LoadingMgr.Instance():UpdateTaskProgress(PreloadResType.PROTOCOL_FAKE, 1)
    protTimerId = nil
  end
end
return CrossServerLoginMgr.Commit()
