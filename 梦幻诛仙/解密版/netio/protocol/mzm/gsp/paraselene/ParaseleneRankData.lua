local OctetsStream = require("netio.OctetsStream")
local ParaseleneRankData = class("ParaseleneRankData")
function ParaseleneRankData:ctor(rank, roleId, name, occupationId, seconds)
  self.rank = rank or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.occupationId = occupationId or nil
  self.seconds = seconds or nil
end
function ParaseleneRankData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.seconds)
end
function ParaseleneRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.occupationId = os:unmarshalInt32()
  self.seconds = os:unmarshalInt32()
end
return ParaseleneRankData
