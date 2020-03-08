local CEnterRoundRobinMapReq = class("CEnterRoundRobinMapReq")
CEnterRoundRobinMapReq.TYPEID = 12616987
function CEnterRoundRobinMapReq:ctor(activity_cfg_id)
  self.id = 12616987
  self.activity_cfg_id = activity_cfg_id or nil
end
function CEnterRoundRobinMapReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CEnterRoundRobinMapReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CEnterRoundRobinMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterRoundRobinMapReq
