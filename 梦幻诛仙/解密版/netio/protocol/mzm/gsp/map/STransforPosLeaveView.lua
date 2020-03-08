local STransforPosLeaveView = class("STransforPosLeaveView")
STransforPosLeaveView.TYPEID = 12590890
function STransforPosLeaveView:ctor(instanceId)
  self.id = 12590890
  self.instanceId = instanceId or nil
end
function STransforPosLeaveView:marshal(os)
  os:marshalInt32(self.instanceId)
end
function STransforPosLeaveView:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
end
function STransforPosLeaveView:sizepolicy(size)
  return size <= 65535
end
return STransforPosLeaveView
