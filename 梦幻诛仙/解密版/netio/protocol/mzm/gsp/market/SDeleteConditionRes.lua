local SDeleteConditionRes = class("SDeleteConditionRes")
SDeleteConditionRes.TYPEID = 12601412
function SDeleteConditionRes:ctor(subid, index)
  self.id = 12601412
  self.subid = subid or nil
  self.index = index or nil
end
function SDeleteConditionRes:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.index)
end
function SDeleteConditionRes:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function SDeleteConditionRes:sizepolicy(size)
  return size <= 65535
end
return SDeleteConditionRes
