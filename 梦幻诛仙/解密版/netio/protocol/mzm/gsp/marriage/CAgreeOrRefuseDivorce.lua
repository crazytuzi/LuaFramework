local CAgreeOrRefuseDivorce = class("CAgreeOrRefuseDivorce")
CAgreeOrRefuseDivorce.TYPEID = 12599820
function CAgreeOrRefuseDivorce:ctor(operator, sessionid)
  self.id = 12599820
  self.operator = operator or nil
  self.sessionid = sessionid or nil
end
function CAgreeOrRefuseDivorce:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.sessionid)
end
function CAgreeOrRefuseDivorce:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.sessionid = os:unmarshalInt64()
end
function CAgreeOrRefuseDivorce:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrRefuseDivorce
