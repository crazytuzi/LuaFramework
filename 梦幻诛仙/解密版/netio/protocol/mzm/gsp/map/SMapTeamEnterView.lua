local TeamMember = require("netio.protocol.mzm.gsp.map.TeamMember")
local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMapTeamEnterView = class("SMapTeamEnterView")
SMapTeamEnterView.TYPEID = 12590876
function SMapTeamEnterView:ctor(teamId, leaderInfo, memberInfo, keyPointPath, curPos, direction, memNum, multiMountsId, multiMountsRoleList)
  self.id = 12590876
  self.teamId = teamId or nil
  self.leaderInfo = leaderInfo or TeamMember.new()
  self.memberInfo = memberInfo or {}
  self.keyPointPath = keyPointPath or {}
  self.curPos = curPos or Location.new()
  self.direction = direction or nil
  self.memNum = memNum or nil
  self.multiMountsId = multiMountsId or nil
  self.multiMountsRoleList = multiMountsRoleList or {}
end
function SMapTeamEnterView:marshal(os)
  os:marshalInt64(self.teamId)
  self.leaderInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.memberInfo))
  for _, v in ipairs(self.memberInfo) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.keyPointPath))
  for _, v in ipairs(self.keyPointPath) do
    v:marshal(os)
  end
  self.curPos:marshal(os)
  os:marshalInt32(self.direction)
  os:marshalInt32(self.memNum)
  os:marshalInt32(self.multiMountsId)
  os:marshalCompactUInt32(table.getn(self.multiMountsRoleList))
  for _, v in ipairs(self.multiMountsRoleList) do
    os:marshalInt64(v)
  end
end
function SMapTeamEnterView:unmarshal(os)
  self.teamId = os:unmarshalInt64()
  self.leaderInfo = TeamMember.new()
  self.leaderInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.TeamMember")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.memberInfo, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.map.Location")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.keyPointPath, v)
  end
  self.curPos = Location.new()
  self.curPos:unmarshal(os)
  self.direction = os:unmarshalInt32()
  self.memNum = os:unmarshalInt32()
  self.multiMountsId = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt64()
    table.insert(self.multiMountsRoleList, v)
  end
end
function SMapTeamEnterView:sizepolicy(size)
  return size <= 65535
end
return SMapTeamEnterView
