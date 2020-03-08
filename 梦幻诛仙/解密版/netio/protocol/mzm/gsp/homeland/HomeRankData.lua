local OctetsStream = require("netio.OctetsStream")
local HomeRankData = class("HomeRankData")
function HomeRankData:ctor(rank, roleId, name, partnerName, point)
  self.rank = rank or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.partnerName = partnerName or nil
  self.point = point or nil
end
function HomeRankData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.roleId)
  os:marshalOctets(self.name)
  os:marshalOctets(self.partnerName)
  os:marshalInt32(self.point)
end
function HomeRankData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalOctets()
  self.partnerName = os:unmarshalOctets()
  self.point = os:unmarshalInt32()
end
return HomeRankData
