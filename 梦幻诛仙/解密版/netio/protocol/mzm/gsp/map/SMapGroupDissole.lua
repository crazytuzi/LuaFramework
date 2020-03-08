local SMapGroupDissole = class("SMapGroupDissole")
SMapGroupDissole.TYPEID = 12590942
function SMapGroupDissole:ctor(group_type, groupid)
  self.id = 12590942
  self.group_type = group_type or nil
  self.groupid = groupid or nil
end
function SMapGroupDissole:marshal(os)
  os:marshalInt32(self.group_type)
  os:marshalInt64(self.groupid)
end
function SMapGroupDissole:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  self.groupid = os:unmarshalInt64()
end
function SMapGroupDissole:sizepolicy(size)
  return size <= 65535
end
return SMapGroupDissole
