local SAttendQingYunZhiActivitySuccess = class("SAttendQingYunZhiActivitySuccess")
SAttendQingYunZhiActivitySuccess.TYPEID = 12614156
function SAttendQingYunZhiActivitySuccess:ctor(activity_cfg_id)
  self.id = 12614156
  self.activity_cfg_id = activity_cfg_id or nil
end
function SAttendQingYunZhiActivitySuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function SAttendQingYunZhiActivitySuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function SAttendQingYunZhiActivitySuccess:sizepolicy(size)
  return size <= 65535
end
return SAttendQingYunZhiActivitySuccess
