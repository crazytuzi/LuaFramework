local SDisAgreeRes = class("SDisAgreeRes")
SDisAgreeRes.TYPEID = 12587019
function SDisAgreeRes:ctor(strangerId)
  self.id = 12587019
  self.strangerId = strangerId or nil
end
function SDisAgreeRes:marshal(os)
  os:marshalInt64(self.strangerId)
end
function SDisAgreeRes:unmarshal(os)
  self.strangerId = os:unmarshalInt64()
end
function SDisAgreeRes:sizepolicy(size)
  return size <= 65535
end
return SDisAgreeRes
