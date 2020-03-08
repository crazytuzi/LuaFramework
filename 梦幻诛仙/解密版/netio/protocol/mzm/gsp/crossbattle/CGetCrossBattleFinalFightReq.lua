local CGetCrossBattleFinalFightReq = class("CGetCrossBattleFinalFightReq")
CGetCrossBattleFinalFightReq.TYPEID = 12617057
function CGetCrossBattleFinalFightReq:ctor(activity_cfg_id)
  self.id = 12617057
  self.activity_cfg_id = activity_cfg_id or nil
end
function CGetCrossBattleFinalFightReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CGetCrossBattleFinalFightReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CGetCrossBattleFinalFightReq:sizepolicy(size)
  return size <= 65535
end
return CGetCrossBattleFinalFightReq
