local CAttendTaskActivityReq = class("CAttendTaskActivityReq")
CAttendTaskActivityReq.TYPEID = 12614158
function CAttendTaskActivityReq:ctor(activity_cfg_id)
  self.id = 12614158
  self.activity_cfg_id = activity_cfg_id or nil
end
function CAttendTaskActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CAttendTaskActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CAttendTaskActivityReq:sizepolicy(size)
  return size <= 65535
end
return CAttendTaskActivityReq
