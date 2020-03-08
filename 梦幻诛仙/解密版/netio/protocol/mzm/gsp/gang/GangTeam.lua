local OctetsStream = require("netio.OctetsStream")
local GangTeam = class("GangTeam")
function GangTeam:ctor(teamid, name, members, leaderid, create_time)
  self.teamid = teamid or nil
  self.name = name or nil
  self.members = members or {}
  self.leaderid = leaderid or nil
  self.create_time = create_time or nil
end
function GangTeam:marshal(os)
  os:marshalInt64(self.teamid)
  os:marshalString(self.name)
  os:marshalCompactUInt32(table.getn(self.members))
  for _, v in ipairs(self.members) do
    v:marshal(os)
  end
  os:marshalInt64(self.leaderid)
  os:marshalInt64(self.create_time)
end
function GangTeam:unmarshal(os)
  self.teamid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.gang.GangTeamMember")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.members, v)
  end
  self.leaderid = os:unmarshalInt64()
  self.create_time = os:unmarshalInt64()
end
return GangTeam
