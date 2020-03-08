local OctetsStream = require("netio.OctetsStream")
local HulaRankData = class("HulaRankData")
function HulaRankData:ctor(rank, roleId, name, occupationId, point)
  self.rank = rank or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.occupationId = occupationId or nil
  self.point = point or nil
end
function HulaRankData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleId)
  os:marshalOctets(self.name)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.point)
end
function HulaRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.occupationId = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
end
return HulaRankData
