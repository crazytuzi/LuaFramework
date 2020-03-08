local SMapGroupLeaveView = class("SMapGroupLeaveView")
SMapGroupLeaveView.TYPEID = 12590940
function SMapGroupLeaveView:ctor(group_type, groupid)
  self.id = 12590940
  self.group_type = group_type or nil
  self.groupid = groupid or nil
end
function SMapGroupLeaveView:marshal(os)
  os:marshalInt32(self.group_type)
  os:marshalInt64(self.groupid)
end
function SMapGroupLeaveView:unmarshal(os)
  self.group_type = os:unmarshalInt32()
  self.groupid = os:unmarshalInt64()
end
function SMapGroupLeaveView:sizepolicy(size)
  return size <= 65535
end
return SMapGroupLeaveView
