local SMapGroupForceLand = class("SMapGroupForceLand")
SMapGroupForceLand.TYPEID = 12590943
function SMapGroupForceLand:ctor(group_type, groupid)
  self.id = 12590943
  self.group_type = group_type or nil
  self.groupid = groupid or nil
end
function SMapGroupForceLand:marshal(os)
  os:marshalInt32(self.group_type)
  os:marshalInt64(self.groupid)
end
function SMapGroupForceLand:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  self.groupid = os:unmarshalInt64()
end
function SMapGroupForceLand:sizepolicy(size)
  return size <= 65535
end
return SMapGroupForceLand
