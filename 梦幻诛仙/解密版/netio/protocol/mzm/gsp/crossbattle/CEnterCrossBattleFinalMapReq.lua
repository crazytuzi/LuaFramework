local CEnterCrossBattleFinalMapReq = class("CEnterCrossBattleFinalMapReq")
CEnterCrossBattleFinalMapReq.TYPEID = 12617068
function CEnterCrossBattleFinalMapReq:ctor(activity_cfg_id)
  self.id = 12617068
  self.activity_cfg_id = activity_cfg_id or nil
end
function CEnterCrossBattleFinalMapReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CEnterCrossBattleFinalMapReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CEnterCrossBattleFinalMapReq:sizepolicy(size)
  return size <= 65535
end
return CEnterCrossBattleFinalMapReq
