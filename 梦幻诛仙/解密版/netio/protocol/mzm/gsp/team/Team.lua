local OctetsStream = require("netio.OctetsStream")
local Team = class("Team")
function Team:ctor(teamid, members, disposition, zhenFaId, zhenFaLv)
  self.teamid = teamid or nil
  self.members = members or {}
  self.disposition = disposition or {}
  self.zhenFaId = zhenFaId or nil
  self.zhenFaLv = zhenFaLv or nil
end
function Team:marshal(os)
  os:marshalInt64(self.teamid)
  os:marshalCompactUInt32(table.getn(self.members))
  for _, v in ipairs(self.members) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.disposition))
  for _, v in ipairs(self.disposition) do
    v:marshal(os)
  end
  os:marshalInt32(self.zhenFaId)
  os:marshalInt32(self.zhenFaLv)
end
function Team:unmarshal(os)
  self.teamid = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamMember")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.members, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamDispositionMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.disposition, v)
  end
  self.zhenFaId = os:unmarshalInt32()
  self.zhenFaLv = os:unmarshalInt32()
end
return Team
