local CAttendQingYunZhiActivityReq = class("CAttendQingYunZhiActivityReq")
CAttendQingYunZhiActivityReq.TYPEID = 12614163
function CAttendQingYunZhiActivityReq:ctor(activity_cfg_id)
  self.id = 12614163
  self.activity_cfg_id = activity_cfg_id or nil
end
function CAttendQingYunZhiActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CAttendQingYunZhiActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CAttendQingYunZhiActivityReq:sizepolicy(size)
  return size <= 65535
end
return CAttendQingYunZhiActivityReq
