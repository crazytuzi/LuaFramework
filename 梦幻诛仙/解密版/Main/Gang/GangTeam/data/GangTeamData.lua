local MODULE_NAME = (...)
local Lplus = require("Lplus")
local GangTeamData = Lplus.Class(MODULE_NAME)
local def = GangTeamData.define
local instance
def.field("table")._gangTeams = nil
def.field("table")._teamId2TeamMap = nil
def.field("table")._roleId2Team = nil
def.field("table")._myTeam = nil
def.field("table")._applyList = nil
def.static("=>", GangTeamData).Instance = function()
  if instance == nil then
    instance = GangTeamData()
    instance:Reset()
  end
  return instance
end
def.method().Reset = function(self)
  self._gangTeams = {}
  self._teamId2TeamMap = {}
  self._roleId2Team = {}
  self._applyList = {}
end
def.method("=>", "table").GetMyTeam = function(self)
  local roleId = _G.GetHeroProp().id
  return self:GetGangTeamByRoleId(roleId)
end
def.method("=>", "boolean").MeIsCaptain = function(self)
  local roleId = _G.GetHeroProp().id
  local myTeam = self:GetGangTeamByRoleId(roleId)
  if myTeam == nil then
    return false
  end
  return myTeam.leaderid:eq(roleId)
end
def.method("userdata", "=>", "table").GetTeamByTeamId = function(self, teamId)
  return self._teamId2TeamMap[teamId:tostring()]
end
def.method("userdata").RmvTeamByTeamId = function(self, teamId)
  local strTeamId = teamId:tostring()
  local team = self._teamId2TeamMap[strTeamId]
  if team then
    self._teamId2TeamMap[strTeamId] = nil
    for i = 1, #self._gangTeams do
      if self._gangTeams[i].teamid:eq(teamId) then
        table.remove(self._gangTeams, i)
        break
      end
    end
    self:rmvRole2teamItems(team)
  end
end
def.method("userdata", "=>", "table").GetTeamByLeaderId = function(self, roleId)
  return self._roleId2TeamMap[roleId:tostring()]
end
def.method("userdata").RmvTeamByLeaderId = function(self, roleId)
  local team = self:GetGangTeamByRoleId(roleId)
  if team then
    self._teamId2TeamMap[team.teamid:tostring()] = nil
    for i = 1, #self._gangTeams do
      if self._gangTeams[i].leaderid:eq(roleId) then
        table.remove(self, _gangTeams, i)
        break
      end
    end
    self:rmvRole2teamItems(team)
  end
end
def.method("userdata", "userdata", "number", "number").UpdateTeamMember = function(self, teamId, roleId, timestamp, opeCode)
  local team = self:GetTeamByTeamId(teamId)
  if team == nil then
    return
  end
  local iTeamPosIdx = 0
  for i = 1, #team.members do
    if team.members[i].roleid:eq(roleId) then
      iTeamPosIdx = i
      if opeCode == 2 then
        self._myTeam = nil
        table.remove(team.members, i)
        self._roleId2Team[roleId:tostring()] = nil
      end
      break
    end
  end
  if opeCode == 1 and iTeamPosIdx == 0 then
    self._myTeam = nil
    table.insert(team.members, {roleid = roleId, join_time = timestamp})
  end
  if 1 > #team.members then
    self:RmvTeamByTeamId(team.teamid)
  end
end
def.method("=>", "table").GetTeamsList = function(self)
  return self._gangTeams
end
def.method("table").SetTeamsData = function(self, teams)
  self._gangTeams = teams
  self._teamId2TeamMap = {}
  self._roleId2Team = {}
  self._myTeam = nil
  for i = 1, #teams do
    local team = teams[i]
    self._teamId2TeamMap[team.teamid:tostring()] = team
    self:addRole2teamItems(team)
    self:sortMembersByJoinTime(team.members)
  end
end
def.method("table").sortMembersByJoinTime = function(self, members)
  if members == nil then
    return
  end
  table.sort(members, function(a, b)
    if a.join_time:lt(b.join_time) then
      return true
    else
      return false
    end
  end)
end
def.method("table").rmvRole2teamItems = function(self, team)
  if team == nil then
    return
  end
  for i = 1, #team.members do
    local member = team.members[i]
    self._roleId2Team[member.roleid:tostring()] = nil
  end
  self._roleId2Team[team.leaderid:tostring()] = nil
end
def.method("table").addRole2teamItems = function(self, team)
  if team == nil then
    return
  end
  for i = 1, #team.members do
    local member = team.members[i]
    self._roleId2Team[member.roleid:tostring()] = team
  end
  self._roleId2Team[team.leaderid:tostring()] = team
end
def.method("userdata", "=>", "userdata").GetTeamIdByRoleId = function(self, roleId)
  if roleId == nil then
    return 0
  end
  return self._roleId2Team[roleId:tostring()].teamid
end
def.method("userdata", "=>", "table").GetGangTeamByRoleId = function(self, roleId)
  if roleId == nil then
    return nil
  end
  local team = self._roleId2Team[roleId:tostring()]
  return team
end
def.method("table").AddNewTeam = function(self, team)
  if team == nil then
    return
  end
  table.insert(self._gangTeams, team)
  self._teamId2TeamMap[team.teamid:tostring()] = team
  self:addRole2teamItems(team)
  self:sortMembersByJoinTime(team.members)
end
def.method("userdata", "userdata").ChgLeader = function(self, teamId, leaderId)
  local team = self:GetTeamByTeamId(teamId)
  if team == nil then
    return
  end
  team.leaderid = leaderId
end
def.method("userdata", "table").AddTeamMember = function(self, teamId, member)
  if teamId == nil then
    return
  end
  local team = self:GetTeamByTeamId(teamId)
  if team == nil then
    return
  end
  table.insert(team.members, member)
  self._roleId2Team[member.roleid:tostring()] = team
end
def.method("userdata", "string").ChgGangTeamName = function(self, teamId, newName)
  if teamId == nil then
    return
  end
  local team = self:GetTeamByTeamId(teamId)
  warn("team", team)
  if team == nil then
    return
  end
  team.name = newName
end
def.method("=>", "table").GetApplyList = function(self)
  return self._applyList
end
def.method("userdata").AddApplyeeFront = function(self, roleId)
  if roleId == nil then
    return
  end
  warn("roleId", roleId:tostring())
  table.insert(self._applyList, 1, roleId)
end
def.method("userdata").AddApplyee = function(self, roleId)
  if roleId == nil then
    return
  end
  table.insert(self._applyList, roleId)
end
def.method("userdata").RmvApplyee = function(self, roleId)
  if roleId == nil then
    return
  end
  for i = 1, #self._applyList do
    if self._applyList[i]:eq(roleId) then
      table.remove(self._applyList, i)
      return
    end
  end
end
def.method().ClearApplierList = function(self)
  self._applyList = {}
end
return GangTeamData.Commit()
