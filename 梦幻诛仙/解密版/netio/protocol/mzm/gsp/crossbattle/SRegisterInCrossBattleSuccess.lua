local SRegisterInCrossBattleSuccess = class("SRegisterInCrossBattleSuccess")
SRegisterInCrossBattleSuccess.TYPEID = 12616984
function SRegisterInCrossBattleSuccess:ctor(activity_cfg_id, corps_id)
  self.id = 12616984
  self.activity_cfg_id = activity_cfg_id or nil
  self.corps_id = corps_id or nil
end
function SRegisterInCrossBattleSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.corps_id)
end
function SRegisterInCrossBattleSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
end
function SRegisterInCrossBattleSuccess:sizepolicy(size)
  return size <= 65535
end
return SRegisterInCrossBattleSuccess
