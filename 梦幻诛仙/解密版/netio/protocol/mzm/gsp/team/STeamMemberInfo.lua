local STeamMemberInfo = class("STeamMemberInfo")
STeamMemberInfo.TYPEID = 12588307
function STeamMemberInfo:ctor(teamMemberInfos)
  self.id = 12588307
  self.teamMemberInfos = teamMemberInfos or {}
end
function STeamMemberInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.teamMemberInfos))
  for _, v in ipairs(self.teamMemberInfos) do
    v:marshal(os)
  end
end
function STeamMemberInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.teamMemberInfos, v)
  end
end
function STeamMemberInfo:sizepolicy(size)
  return size <= 65535
end
return STeamMemberInfo
