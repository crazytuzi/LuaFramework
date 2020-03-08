local SRoleColorDes = class("SRoleColorDes")
SRoleColorDes.TYPEID = 12597259
function SRoleColorDes:ctor(hairid, clothid)
  self.id = 12597259
  self.hairid = hairid or nil
  self.clothid = clothid or nil
end
function SRoleColorDes:marshal(os)
  os:marshalInt32(self.hairid)
  os:marshalInt32(self.clothid)
end
function SRoleColorDes:unmarshal(os)
  self.hairid = os:unmarshalInt32()
  self.clothid = os:unmarshalInt32()
end
function SRoleColorDes:sizepolicy(size)
  return size <= 65535
end
return SRoleColorDes
