local CUnregisterInCrossBattleReq = class("CUnregisterInCrossBattleReq")
CUnregisterInCrossBattleReq.TYPEID = 12616979
function CUnregisterInCrossBattleReq:ctor(activity_cfg_id)
  self.id = 12616979
  self.activity_cfg_id = activity_cfg_id or nil
end
function CUnregisterInCrossBattleReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CUnregisterInCrossBattleReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CUnregisterInCrossBattleReq:sizepolicy(size)
  return size <= 65535
end
return CUnregisterInCrossBattleReq
