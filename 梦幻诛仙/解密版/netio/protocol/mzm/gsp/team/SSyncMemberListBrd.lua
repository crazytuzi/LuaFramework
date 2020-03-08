local SSyncMemberListBrd = class("SSyncMemberListBrd")
SSyncMemberListBrd.TYPEID = 12588318
function SSyncMemberListBrd:ctor(members, disposition, teamMemberInfos)
  self.id = 12588318
  self.members = members or {}
  self.disposition = disposition or {}
  self.teamMemberInfos = teamMemberInfos or {}
end
function SSyncMemberListBrd:marshal(os)
  os:marshalCompactUInt32(table.getn(self.members))
  for _, v in ipairs(self.members) do
    os:marshalInt64(v)
  end
  os:marshalCompactUInt32(table.getn(self.disposition))
  for _, v in ipairs(self.disposition) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.teamMemberInfos))
  for _, v in ipairs(self.teamMemberInfos) do
    v:marshal(os)
  end
end
function SSyncMemberListBrd:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.members, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamDispositionMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.disposition, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.team.TeamMemberInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.teamMemberInfos, v)
  end
end
function SSyncMemberListBrd:sizepolicy(size)
  return size <= 65535
end
return SSyncMemberListBrd
