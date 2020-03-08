local CLeaveRoundRobinMapReq = class("CLeaveRoundRobinMapReq")
CLeaveRoundRobinMapReq.TYPEID = 12616978
function CLeaveRoundRobinMapReq:ctor(activity_cfg_id)
  self.id = 12616978
  self.activity_cfg_id = activity_cfg_id or nil
end
function CLeaveRoundRobinMapReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CLeaveRoundRobinMapReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CLeaveRoundRobinMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveRoundRobinMapReq
