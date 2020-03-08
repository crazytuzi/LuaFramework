local CAgreeCreateSworn = class("CAgreeCreateSworn")
CAgreeCreateSworn.TYPEID = 12597775
function CAgreeCreateSworn:ctor(swornid)
  self.id = 12597775
  self.swornid = swornid or nil
end
function CAgreeCreateSworn:marshal(os)
  os:marshalInt64(self.swornid)
end
function CAgreeCreateSworn:unmarshal(os)
  self.swornid = os:unmarshalInt64()
end
function CAgreeCreateSworn:sizepolicy(size)
  return size <= 65535
end
return CAgreeCreateSworn
