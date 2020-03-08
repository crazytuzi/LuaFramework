local SAgreeOrRefusePregnantBelong = class("SAgreeOrRefusePregnantBelong")
SAgreeOrRefusePregnantBelong.TYPEID = 12609329
function SAgreeOrRefusePregnantBelong:ctor(operator)
  self.id = 12609329
  self.operator = operator or nil
end
function SAgreeOrRefusePregnantBelong:marshal(os)
  os:marshalInt32(self.operator)
end
function SAgreeOrRefusePregnantBelong:unmarshal(os)
  self.operator = os:unmarshalInt32()
end
function SAgreeOrRefusePregnantBelong:sizepolicy(size)
  return size <= 65535
end
return SAgreeOrRefusePregnantBelong
