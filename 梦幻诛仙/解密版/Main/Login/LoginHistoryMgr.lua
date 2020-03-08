local Lplus = require("Lplus")
local LoginHistoryMgr = Lplus.Class("LoginHistoryMgr")
local LoginModule = Lplus.ForwardDeclare("LoginModule")
local LoginUtility = require("Main.Login.LoginUtility")
local ServerListMgr = require("Main.Login.ServerListMgr")
local def = LoginHistoryMgr.define
local instance
def.static("=>", LoginHistoryMgr).Instance = function()
  if instance == nil then
    instance = LoginHistoryMgr()
    instance:OnInit()
  end
  return instance
end
def.method().OnInit = function(self)
  Event.RegisterEventWithContext(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Change, LoginHistoryMgr.OnAvatarChange, self)
  Event.RegisterEventWithContext(ModuleId.AVATAR, gmodule.notifyId.Avatar.Avatar_Frame_Change, LoginHistoryMgr.OnAvatarFrameChange, self)
end
def.method().LoadCurUserLoginHistory = function(self)
  local loginHistory = LoginUtility.Instance():GetUserLoginHistory(LoginModule.Instance().userName)
  if loginHistory then
    local lastLoginCfg = loginHistory[1]
    local serverCfg = ServerListMgr.Instance():GetValidServerCfg(lastLoginCfg.serverId)
    if serverCfg == nil then
      if platform ~= 0 then
        warn("Missing servercfg, serverId = ", lastLoginCfg.serverId)
      end
      return
    end
    LoginModule.Instance().selectedServerNo = lastLoginCfg.serverId
    LoginModule.Instance().lastLoginRoleId = LoginUtility.GetServerLastLoginRoleId(LoginModule.Instance().userName, lastLoginCfg.serverId)
    LoginModule.Instance().serverIp = serverCfg.address
    LoginModule.Instance().serverPort = tostring(math.random(serverCfg.beginPort, serverCfg.endPort))
  end
end
def.method("string", "number", "userdata").SaveLoginHistory = function(self, userName, serverId, lastLoginRoleId)
  if serverId == 0 then
    return
  end
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
  local heroProp = HeroPropMgr.Instance():GetHeroProp() or {}
  local cachedRoleList = LoginModule.Instance():GetCachedRoleList() or {}
  local cachedRoleMap = {}
  for i, v in ipairs(cachedRoleList) do
    local roleidStr = v.roleid
    if type(v.roleid) ~= "string" then
      roleidStr = tostring(v.roleid)
    end
    cachedRoleMap[roleidStr] = v
  end
  local roleList = LoginModule.Instance():GetRoleList() or cachedRoleList
  local lastRoleId = lastLoginRoleId
  local pos = 1
  local simpleRoleList = {}
  for i, role in ipairs(roleList) do
    local simpleRole = {}
    simpleRole.roleid = role.roleid
    simpleRole.basic = {}
    simpleRole.basic.occupation = role.basic.occupation
    simpleRole.basic.gender = role.basic.gender
    simpleRole.basic.name = role.basic.name
    simpleRole.basic.level = role.basic.level
    if simpleRole.roleid == heroProp.id and heroProp.name ~= nil then
      simpleRole.basic.name = heroProp.name
      simpleRole.basic.level = heroProp.level
    end
    local cachedRole = cachedRoleMap[tostring(role.roleid)]
    if cachedRole then
      simpleRole.avatarId = cachedRole.avatarId
      simpleRole.avatarFrameId = cachedRole.avatarFrameId
    end
    table.insert(simpleRoleList, simpleRole)
    if role.roleid == lastRoleId then
      pos = i
    end
  end
  if pos ~= 1 then
    local tmp = simpleRoleList[pos]
    table.remove(simpleRoleList, pos)
    table.insert(simpleRoleList, 1, tmp)
    tmp = nil
  end
  LoginUtility.Instance():AddLoginHistory(userName, serverId, simpleRoleList)
  LoginUtility.Instance():SaveLoginHistory()
end
def.method("=>", "table").GetCurLoginRoleCacheInfo = function(self)
  local cachedRoleList = LoginModule.Instance():GetCachedRoleList()
  if cachedRoleList == nil then
    return nil
  end
  local HeroPropMgr = require("Main.Hero.mgr.HeroPropMgr")
  local heroProp = HeroPropMgr.Instance():GetHeroProp()
  if heroProp == nil then
    return nil
  end
  local cachedRoleMap = {}
  local curRole
  for i, v in ipairs(cachedRoleList) do
    local roleid = v.roleid
    if type(roleid) == "string" then
      roleid = Int64.ParseString(roleid)
    end
    if roleid == heroProp.id then
      curRole = v
      break
    end
  end
  return curRole
end
def.method("table").OnAvatarChange = function(self, params)
  local cachedRole = self:GetCurLoginRoleCacheInfo()
  if cachedRole == nil then
    return
  end
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarId = AvatarInterface.Instance():getCurAvatarId()
  if avatarId ~= cachedRole.avatarId then
    cachedRole.avatarId = avatarId
    LoginModule.Instance():SaveLoginInfo()
  end
end
def.method("table").OnAvatarFrameChange = function(self, params)
  local cachedRole = self:GetCurLoginRoleCacheInfo()
  if cachedRole == nil then
    return
  end
  local AvatarInterface = require("Main.Avatar.AvatarInterface")
  local avatarFrameId = AvatarInterface.Instance():getCurAvatarFrameId()
  if avatarFrameId ~= cachedRole.avatarFrameId then
    cachedRole.avatarFrameId = avatarFrameId
    LoginModule.Instance():SaveLoginInfo()
  end
end
LoginHistoryMgr.Commit()
return LoginHistoryMgr
