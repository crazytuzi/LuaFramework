local SReceivePayNewYear = class("SReceivePayNewYear")
SReceivePayNewYear.TYPEID = 12609026
function SReceivePayNewYear:ctor(role_id, role_name)
  self.id = 12609026
  self.role_id = role_id or nil
  self.role_name = role_name or nil
end
function SReceivePayNewYear:marshal(os)
  os:marshalInt64(self.role_id)
  os:marshalOctets(self.role_name)
end
function SReceivePayNewYear:unmarshal(os)
  self.role_id = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
end
function SReceivePayNewYear:sizepolicy(size)
  return size <= 65535
end
return SReceivePayNewYear
