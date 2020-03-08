local CGetRegisterInfoInCrossBattleReq = class("CGetRegisterInfoInCrossBattleReq")
CGetRegisterInfoInCrossBattleReq.TYPEID = 12616970
function CGetRegisterInfoInCrossBattleReq:ctor(activity_cfg_id, corps_id)
  self.id = 12616970
  self.activity_cfg_id = activity_cfg_id or nil
  self.corps_id = corps_id or nil
end
function CGetRegisterInfoInCrossBattleReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.corps_id)
end
function CGetRegisterInfoInCrossBattleReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
end
function CGetRegisterInfoInCrossBattleReq:sizepolicy(size)
  return size <= 65535
end
return CGetRegisterInfoInCrossBattleReq
