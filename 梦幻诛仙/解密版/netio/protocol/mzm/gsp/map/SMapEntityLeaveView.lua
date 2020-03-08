local SMapEntityLeaveView = class("SMapEntityLeaveView")
SMapEntityLeaveView.TYPEID = 12590949
function SMapEntityLeaveView:ctor(entity_type, instanceid)
  self.id = 12590949
  self.entity_type = entity_type or nil
  self.instanceid = instanceid or nil
end
function SMapEntityLeaveView:marshal(os)
  os:marshalInt32(self.entity_type)
  os:marshalInt64(self.instanceid)
end
function SMapEntityLeaveView:unmarshal(os)
  self.entity_type = os:unmarshalInt32()
  self.instanceid = os:unmarshalInt64()
end
function SMapEntityLeaveView:sizepolicy(size)
  return size <= 65535
end
return SMapEntityLeaveView
