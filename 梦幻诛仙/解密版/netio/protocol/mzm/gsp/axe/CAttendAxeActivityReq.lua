local CAttendAxeActivityReq = class("CAttendAxeActivityReq")
CAttendAxeActivityReq.TYPEID = 12614915
function CAttendAxeActivityReq:ctor(activity_cfg_id)
  self.id = 12614915
  self.activity_cfg_id = activity_cfg_id or nil
end
function CAttendAxeActivityReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CAttendAxeActivityReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CAttendAxeActivityReq:sizepolicy(size)
  return size <= 65535
end
return CAttendAxeActivityReq
