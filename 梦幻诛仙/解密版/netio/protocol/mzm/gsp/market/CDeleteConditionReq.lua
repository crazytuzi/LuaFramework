local CDeleteConditionReq = class("CDeleteConditionReq")
CDeleteConditionReq.TYPEID = 12601405
function CDeleteConditionReq:ctor(subid, index)
  self.id = 12601405
  self.subid = subid or nil
  self.index = index or nil
end
function CDeleteConditionReq:marshal(os)
  os:marshalInt32(self.subid)
  os:marshalInt32(self.index)
end
function CDeleteConditionReq:unmarshal(os)
  self.subid = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
end
function CDeleteConditionReq:sizepolicy(size)
  return size <= 65535
end
return CDeleteConditionReq
