local CMasterRelieveShiTuRelation = class("CMasterRelieveShiTuRelation")
CMasterRelieveShiTuRelation.TYPEID = 12601611
function CMasterRelieveShiTuRelation:ctor(apprenticeRoleId)
  self.id = 12601611
  self.apprenticeRoleId = apprenticeRoleId or nil
end
function CMasterRelieveShiTuRelation:marshal(os)
  os:marshalInt64(self.apprenticeRoleId)
end
function CMasterRelieveShiTuRelation:unmarshal(os)
  self.apprenticeRoleId = os:unmarshalInt64()
end
function CMasterRelieveShiTuRelation:sizepolicy(size)
  return size <= 65535
end
return CMasterRelieveShiTuRelation
