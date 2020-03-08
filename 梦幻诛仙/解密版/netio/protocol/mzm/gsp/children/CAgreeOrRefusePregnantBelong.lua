local CAgreeOrRefusePregnantBelong = class("CAgreeOrRefusePregnantBelong")
CAgreeOrRefusePregnantBelong.TYPEID = 12609331
CAgreeOrRefusePregnantBelong.REFUSE = 0
CAgreeOrRefusePregnantBelong.AGREE = 1
function CAgreeOrRefusePregnantBelong:ctor(operator, session_id)
  self.id = 12609331
  self.operator = operator or nil
  self.session_id = session_id or nil
end
function CAgreeOrRefusePregnantBelong:marshal(os)
  os:marshalInt32(self.operator)
  os:marshalInt64(self.session_id)
end
function CAgreeOrRefusePregnantBelong:unmarshal(os)
  self.operator = os:unmarshalInt32()
  self.session_id = os:unmarshalInt64()
end
function CAgreeOrRefusePregnantBelong:sizepolicy(size)
  return size <= 65535
end
return CAgreeOrRefusePregnantBelong
