local CLeaveCrossBattleFinalMapReq = class("CLeaveCrossBattleFinalMapReq")
CLeaveCrossBattleFinalMapReq.TYPEID = 12617061
function CLeaveCrossBattleFinalMapReq:ctor(activity_cfg_id)
  self.id = 12617061
  self.activity_cfg_id = activity_cfg_id or nil
end
function CLeaveCrossBattleFinalMapReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CLeaveCrossBattleFinalMapReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CLeaveCrossBattleFinalMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveCrossBattleFinalMapReq
