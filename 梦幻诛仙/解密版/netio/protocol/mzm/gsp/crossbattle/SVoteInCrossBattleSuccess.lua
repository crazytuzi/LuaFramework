local SVoteInCrossBattleSuccess = class("SVoteInCrossBattleSuccess")
SVoteInCrossBattleSuccess.TYPEID = 12616965
function SVoteInCrossBattleSuccess:ctor(activity_cfg_id, target_corps_id)
  self.id = 12616965
  self.activity_cfg_id = activity_cfg_id or nil
  self.target_corps_id = target_corps_id or nil
end
function SVoteInCrossBattleSuccess:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.target_corps_id)
end
function SVoteInCrossBattleSuccess:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.target_corps_id = os:unmarshalInt64()
end
function SVoteInCrossBattleSuccess:sizepolicy(size)
  return size <= 65535
end
return SVoteInCrossBattleSuccess
