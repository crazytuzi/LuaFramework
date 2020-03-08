local CPayNewYear = class("CPayNewYear")
CPayNewYear.TYPEID = 12609027
function CPayNewYear:ctor(role_id)
  self.id = 12609027
  self.role_id = role_id or nil
end
function CPayNewYear:marshal(os)
  os:marshalInt64(self.role_id)
end
function CPayNewYear:unmarshal(os)
  self.role_id = os:unmarshalInt64()
end
function CPayNewYear:sizepolicy(size)
  return size <= 65535
end
return CPayNewYear
