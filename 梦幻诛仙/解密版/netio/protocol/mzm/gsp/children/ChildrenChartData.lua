local OctetsStream = require("netio.OctetsStream")
local ChildrenChartData = class("ChildrenChartData")
function ChildrenChartData:ctor(rank, child_id, role_id, child_name, role_name, rating)
  self.rank = rank or nil
  self.child_id = child_id or nil
  self.role_id = role_id or nil
  self.child_name = child_name or nil
  self.role_name = role_name or nil
  self.rating = rating or nil
end
function ChildrenChartData:marshal(os)
  os:marshalInt32(self.rank)
  os:marshalInt64(self.child_id)
  os:marshalInt64(self.role_id)
  os:marshalOctets(self.child_name)
  os:marshalOctets(self.role_name)
  os:marshalInt32(self.rating)
end
function ChildrenChartData:unmarshal(os)
  self.rank = os:unmarshalInt32()
  self.child_id = os:unmarshalInt64()
  self.role_id = os:unmarshalInt64()
  self.child_name = os:unmarshalOctets()
  self.role_name = os:unmarshalOctets()
  self.rating = os:unmarshalInt32()
end
return ChildrenChartData
