local SUnregisterInCrossBattleSuccess = class("SUnregisterInCrossBattleSuccess")
SUnregisterInCrossBattleSuccess.TYPEID = 12616973
SUnregisterInCrossBattleSuccess.REASON_ACTIVE = 0
SUnregisterInCrossBattleSuccess.REASON_CORPS_MEMBER_NUM_DISSATISFIED = 1
function SUnregisterInCrossBattleSuccess:ctor(activity_cfg_id, corps_id, reason)
  self.id = 12616973
  self.activity_cfg_id = activity_cfg_id or nil
  self.corps_id = corps_id or nil
  self.reason = reason or nil
end
function SUnregisterInCrossBattleSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.corps_id)
  os:marshalInt32(self.reason)
end
function SUnregisterInCrossBattleSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.corps_id = os:unmarshalInt64()
  self.reason = os:unmarshalInt32()
end
function SUnregisterInCrossBattleSuccess:sizepolicy(size)
  return size <= 65535
end
return SUnregisterInCrossBattleSuccess
