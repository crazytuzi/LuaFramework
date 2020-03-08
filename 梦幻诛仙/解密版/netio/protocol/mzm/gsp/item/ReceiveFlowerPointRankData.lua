local OctetsStream = require("netio.OctetsStream")
local ReceiveFlowerPointRankData = class("ReceiveFlowerPointRankData")
function ReceiveFlowerPointRankData:ctor(no, roleId, name, occupationId, point)
  self.no = no or nil
  self.roleId = roleId or nil
  self.name = name or nil
  self.occupationId = occupationId or nil
  self.point = point or nil
end
function ReceiveFlowerPointRankData:marshal(os)
  os:marshalInt32(self.no)
  os:marshalInt64(self.roleId)
  os:marshalString(self.name)
  os:marshalInt32(self.occupationId)
  os:marshalInt32(self.point)
end
function ReceiveFlowerPointRankData:unmarshal(os)
  self.no = os:unmarshalInt32()
  self.roleId = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.occupationId = os:unmarshalInt32()
  self.point = os:unmarshalInt32()
end
return ReceiveFlowerPointRankData
