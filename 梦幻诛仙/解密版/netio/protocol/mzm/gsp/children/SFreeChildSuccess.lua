local SFreeChildSuccess = class("SFreeChildSuccess")
SFreeChildSuccess.TYPEID = 12609334
function SFreeChildSuccess:ctor(child_id)
  self.id = 12609334
  self.child_id = child_id or nil
end
function SFreeChildSuccess:marshal(os)
  os:marshalInt64(self.child_id)
end
function SFreeChildSuccess:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function SFreeChildSuccess:sizepolicy(size)
  return size <= 65535
end
return SFreeChildSuccess
