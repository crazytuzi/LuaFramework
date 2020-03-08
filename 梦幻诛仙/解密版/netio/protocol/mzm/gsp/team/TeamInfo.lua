local OctetsStream = require("netio.OctetsStream")
local TeamInfo = class("TeamInfo")
function TeamInfo:ctor(teamId, members)
  self.teamId = teamId or nil
  self.members = members or {}
end
function TeamInfo:marshal(os)
  os:marshalInt64(self.teamId)
  os:marshalCompactUInt32(table.getn(self.members))
  for _, v in ipairs(self.members) do
    v:marshal(os)
  end
end
function TeamInfo:unmarshal(os)
  self.teamId = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.members, v)
  end
end
return TeamInfo
