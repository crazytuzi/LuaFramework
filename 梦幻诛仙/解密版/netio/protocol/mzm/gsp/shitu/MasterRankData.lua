local OctetsStream = require("netio.OctetsStream")
local MasterRankData = class("MasterRankData")
function MasterRankData:ctor(rank, roleId, name, apprenticeSize, occupationId)
  self.rank = rank or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.apprenticeSize = apprenticeSize or nil
  self.occupationId = occupationId or nil
end
function MasterRankData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.apprenticeSize)
  os:marshalInt32(self.occupationId)
end
function MasterRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.apprenticeSize = os:unmarshalInt32()
  self.occupationId = os:unmarshalInt32()
end
return MasterRankData
