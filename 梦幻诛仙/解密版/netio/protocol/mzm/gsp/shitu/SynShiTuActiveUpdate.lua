local SynShiTuActiveUpdate = class("SynShiTuActiveUpdate")
SynShiTuActiveUpdate.TYPEID = 12601646
function SynShiTuActiveUpdate:ctor(role_id, active_value)
  self.id = 12601646
  self.role_id = role_id or nil
  self.active_value = active_value or nil
end
function SynShiTuActiveUpdate:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalInt32(self.active_value)
end
function SynShiTuActiveUpdate:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.active_value = os:unmarshalInt32()
end
function SynShiTuActiveUpdate:sizepolicy(size)
  return size <= 65535
end
return SynShiTuActiveUpdate
