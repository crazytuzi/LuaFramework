local SGetRegisterInfoInCrossBattleSuccess = class("SGetRegisterInfoInCrossBattleSuccess")
SGetRegisterInfoInCrossBattleSuccess.TYPEID = 12616982
function SGetRegisterInfoInCrossBattleSuccess:ctor(activity_cfg_id, corps_id, register_info)
  self.id = 12616982
  self.activity_cfg_id = activity_cfg_id or nil
  self.corps_id = corps_id or nil
  self.register_info = register_info or nil
end
function SGetRegisterInfoInCrossBattleSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.corps_id)
  os:marshalUInt8(self.register_info)
end
function SGetRegisterInfoInCrossBattleSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
  self.register_info = os:unmarshalUInt8()
end
function SGetRegisterInfoInCrossBattleSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetRegisterInfoInCrossBattleSuccess
