local CRegisterInCrossBattleReq = class("CRegisterInCrossBattleReq")
CRegisterInCrossBattleReq.TYPEID = 12616969
function CRegisterInCrossBattleReq:ctor(activity_cfg_id)
  self.id = 12616969
  self.activity_cfg_id = activity_cfg_id or nil
end
function CRegisterInCrossBattleReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CRegisterInCrossBattleReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CRegisterInCrossBattleReq:sizepolicy(size)
  return size <= 65535
end
return CRegisterInCrossBattleReq
