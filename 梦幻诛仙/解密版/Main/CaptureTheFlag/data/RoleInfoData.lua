local Lplus = require("Lplus")
local RoleInfoData = Lplus.Class("RoleInfoData")
local def = RoleInfoData.define
local ServerListMgr = require("Main.Login.ServerListMgr")
def.field("table").roles = nil
def.field("table").teams = nil
def.static("=>", RoleInfoData).new = function()
  local recorder = RoleInfoData()
  recorder.roles = {}
  recorder.teams = {}
  return recorder
end
def.method("table", "userdata", "number").AddRoleToTeam = function(self, roleInfo, roleId, teamId)
  if self.teams[teamId] == nil then
    self.teams[teamId] = {}
  end
  self.teams[teamId][roleId:tostring()] = roleId
  local zoneCfg = ServerListMgr.Instance():GetServerCfg(roleInfo.zoneId)
  self.roles[roleId:tostring()] = {
    roleId = roleId,
    name = GetStringFromOcts(roleInfo.name),
    gender = roleInfo.gender,
    occupation = roleInfo.occupation,
    level = roleInfo.level,
    avatarId = roleInfo.avatarId,
    zoneId = roleInfo.zoneId,
    zoneName = zoneCfg and zoneCfg.name or "",
    state = roleInfo.state,
    teamId = teamId,
    index = roleInfo.num,
    startPos = nil
  }
end
def.method("userdata", "=>", "table").GetRoleInfo = function(self, roleId)
  return self.roles[roleId:tostring()]
end
def.method("userdata", "number").SetRoleState = function(self, roleId, state)
  if self.roles[roleId:tostring()] then
    self.roles[roleId:tostring()].state = state
  end
end
def.method("number", "=>", "table").GetTeamRoles = function(self, teamId)
  if self.teams and self.teams[teamId] then
    return self.teams[teamId]
  else
    return {}
  end
end
def.method("=>", "table").GetAllRoles = function(self)
  return self.roles
end
def.method("userdata", "table").SetStartPos = function(self, roleId, pos)
  local roleInfo = self:GetRoleInfo(roleId)
  if roleInfo then
    roleInfo.startPos = pos
  end
end
return RoleInfoData.Commit()
