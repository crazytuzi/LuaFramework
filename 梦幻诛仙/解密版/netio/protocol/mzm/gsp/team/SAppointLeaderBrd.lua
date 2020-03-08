local SAppointLeaderBrd = class("SAppointLeaderBrd")
SAppointLeaderBrd.TYPEID = 12588322
function SAppointLeaderBrd:ctor(new_leader, teamMemberInfos)
  self.id = 12588322
  self.new_leader = new_leader or nil
  self.teamMemberInfos = teamMemberInfos or {}
end
function SAppointLeaderBrd:marshal(os)
  os:marshalInt64(self.new_leader)
  os:marshalCompactUInt32(table.getn(self.teamMemberInfos))
  for _, v in ipairs(self.teamMemberInfos) do
    v:marshal(os)
  end
end
function SAppointLeaderBrd:unmarshal(os)
  self.new_leader = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.teamMemberInfos, v)
  end
end
function SAppointLeaderBrd:sizepolicy(size)
  return size <= 65535
end
return SAppointLeaderBrd
