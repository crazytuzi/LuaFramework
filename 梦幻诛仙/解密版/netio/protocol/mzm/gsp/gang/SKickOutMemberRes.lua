local SKickOutMemberRes = class("SKickOutMemberRes")
SKickOutMemberRes.TYPEID = 12589898
function SKickOutMemberRes:ctor(costVigor)
  self.id = 12589898
  self.costVigor = costVigor or nil
end
function SKickOutMemberRes:marshal(os)
  os:marshalInt32(self.costVigor)
end
function SKickOutMemberRes:unmarshal(os)
  self.costVigor = os:unmarshalInt32()
end
function SKickOutMemberRes:sizepolicy(size)
  return size <= 65535
end
return SKickOutMemberRes
