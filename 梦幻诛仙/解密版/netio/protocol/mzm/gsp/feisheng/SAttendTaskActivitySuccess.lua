local SAttendTaskActivitySuccess = class("SAttendTaskActivitySuccess")
SAttendTaskActivitySuccess.TYPEID = 12614165
function SAttendTaskActivitySuccess:ctor(activity_cfg_id)
  self.id = 12614165
  self.activity_cfg_id = activity_cfg_id or nil
end
function SAttendTaskActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SAttendTaskActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SAttendTaskActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SAttendTaskActivitySuccess
