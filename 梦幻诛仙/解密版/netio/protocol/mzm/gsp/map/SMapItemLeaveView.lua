local SMapItemLeaveView = class("SMapItemLeaveView")
SMapItemLeaveView.TYPEID = 12590893
function SMapItemLeaveView:ctor(instanceId)
  self.id = 12590893
  self.instanceId = instanceId or nil
end
function SMapItemLeaveView:marshal(os)
  os:marshalInt32(self.instanceId)
end
function SMapItemLeaveView:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
end
function SMapItemLeaveView:sizepolicy(size)
  return size <= 65535
end
return SMapItemLeaveView
