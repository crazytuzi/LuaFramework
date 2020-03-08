local SMapTeamInfo = class("SMapTeamInfo")
SMapTeamInfo.TYPEID = 12590885
function SMapTeamInfo:ctor(teamId, teamLeader, followerIds, memNum, multiMountsId, multiMountsRoleList)
  self.id = 12590885
  self.teamId = teamId or nil
  self.teamLeader = teamLeader or nil
  self.followerIds = followerIds or {}
  self.memNum = memNum or nil
  self.multiMountsId = multiMountsId or nil
  self.multiMountsRoleList = multiMountsRoleList or {}
end
function SMapTeamInfo:marshal(os)
  os:marshalInt64(self.teamId)
  os:marshalInt64(self.teamLeader)
  os:marshalCompactUInt32(table.getn(self.followerIds))
  for _, v in ipairs(self.followerIds) do
    os:marshalInt64(v)
  end
  os:marshalInt32(self.memNum)
  os:marshalInt32(self.multiMountsId)
  os:marshalCompactUInt32(table.getn(self.multiMountsRoleList))
  for _, v in ipairs(self.multiMountsRoleList) do
    os:marshalInt64(v)
  end
end
function SMapTeamInfo:unmarshal(os)
  self.teamId = os:unmarshalInt64()
  self.teamLeader = os:unmarshalInt64()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.followerIds, v)
  end
  self.memNum = os:unmarshalInt32()
  self.multiMountsId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.multiMountsRoleList, v)
  end
end
function SMapTeamInfo:sizepolicy(size)
  return size <= 65535
end
return SMapTeamInfo
