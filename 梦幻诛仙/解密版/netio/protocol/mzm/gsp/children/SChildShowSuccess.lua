local SChildShowSuccess = class("SChildShowSuccess")
SChildShowSuccess.TYPEID = 12609322
function SChildShowSuccess:ctor(child_id, child_period)
  self.id = 12609322
  self.child_id = child_id or nil
  self.child_period = child_period or nil
end
function SChildShowSuccess:marshal(os)
  os:marshalInt64(self.child_id)
  os:marshalInt32(self.child_period)
end
function SChildShowSuccess:unmarshal(os)
  self.child_id = os:unmarshalInt64()
  self.child_period = os:unmarshalInt32()
end
function SChildShowSuccess:sizepolicy(size)
  return size <= 65535
end
return SChildShowSuccess
