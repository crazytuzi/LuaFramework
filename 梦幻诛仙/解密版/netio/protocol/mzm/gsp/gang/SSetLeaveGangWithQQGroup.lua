local SSetLeaveGangWithQQGroup = class("SSetLeaveGangWithQQGroup")
SSetLeaveGangWithQQGroup.TYPEID = 12589951
function SSetLeaveGangWithQQGroup:ctor(groupOpenId)
  self.id = 12589951
  self.groupOpenId = groupOpenId or nil
end
function SSetLeaveGangWithQQGroup:marshal(os)
  os:marshalString(self.groupOpenId)
end
function SSetLeaveGangWithQQGroup:unmarshal(os)
  self.groupOpenId = os:unmarshalString()
end
function SSetLeaveGangWithQQGroup:sizepolicy(size)
  return size <= 65535
end
return SSetLeaveGangWithQQGroup
