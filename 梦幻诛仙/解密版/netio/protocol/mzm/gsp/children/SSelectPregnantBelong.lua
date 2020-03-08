local SSelectPregnantBelong = class("SSelectPregnantBelong")
SSelectPregnantBelong.TYPEID = 12609327
function SSelectPregnantBelong:ctor(belong_role_id, session_id)
  self.id = 12609327
  self.belong_role_id = belong_role_id or nil
  self.session_id = session_id or nil
end
function SSelectPregnantBelong:marshal(os)
  os:marshalInt64(self.belong_role_id)
  os:marshalInt64(self.session_id)
end
function SSelectPregnantBelong:unmarshal(os)
  self.belong_role_id = os:unmarshalInt64()
  self.session_id = os:unmarshalInt64()
end
function SSelectPregnantBelong:sizepolicy(size)
  return size <= 65535
end
return SSelectPregnantBelong
