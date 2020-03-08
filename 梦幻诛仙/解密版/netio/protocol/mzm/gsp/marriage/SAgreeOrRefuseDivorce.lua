local SAgreeOrRefuseDivorce = class("SAgreeOrRefuseDivorce")
SAgreeOrRefuseDivorce.TYPEID = 12599821
function SAgreeOrRefuseDivorce:ctor(operator, roleid)
  self.id = 12599821
  self.operator = operator or nil
  self.roleid = roleid or nil
end
function SAgreeOrRefuseDivorce:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.roleid)
end
function SAgreeOrRefuseDivorce:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
end
function SAgreeOrRefuseDivorce:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrRefuseDivorce
