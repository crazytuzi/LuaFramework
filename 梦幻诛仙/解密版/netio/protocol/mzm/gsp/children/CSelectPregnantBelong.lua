local CSelectPregnantBelong = class("CSelectPregnantBelong")
CSelectPregnantBelong.TYPEID = 12609325
function CSelectPregnantBelong:ctor(belong_role_id)
  self.id = 12609325
  self.belong_role_id = belong_role_id or nil
end
function CSelectPregnantBelong:marshal(os)
  os:marshalInt64(self.belong_role_id)
end
function CSelectPregnantBelong:unmarshal(os)
  self.belong_role_id = os:unmarshalInt64()
end
function CSelectPregnantBelong:sizepolicy(size)
  return size <= 65535
end
return CSelectPregnantBelong
