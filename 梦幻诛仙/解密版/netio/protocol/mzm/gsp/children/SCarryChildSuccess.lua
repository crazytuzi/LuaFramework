local SCarryChildSuccess = class("SCarryChildSuccess")
SCarryChildSuccess.TYPEID = 12609286
function SCarryChildSuccess:ctor(child_id)
  self.id = 12609286
  self.child_id = child_id or nil
end
function SCarryChildSuccess:marshal(os)
  os:marshalInt64(self.child_id)
end
function SCarryChildSuccess:unmarshal(os)
  self.child_id = os:unmarshalInt64()
end
function SCarryChildSuccess:sizepolicy(size)
  return size <= 65535
end
return SCarryChildSuccess
