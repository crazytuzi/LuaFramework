local SAttendAxeActivitySuccess = class("SAttendAxeActivitySuccess")
SAttendAxeActivitySuccess.TYPEID = 12614913
function SAttendAxeActivitySuccess:ctor(activity_cfg_id, sortid)
  self.id = 12614913
  self.activity_cfg_id = activity_cfg_id or nil
  self.sortid = sortid or nil
end
function SAttendAxeActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.sortid)
end
function SAttendAxeActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.sortid = os:unmarshalInt32()
end
function SAttendAxeActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SAttendAxeActivitySuccess
