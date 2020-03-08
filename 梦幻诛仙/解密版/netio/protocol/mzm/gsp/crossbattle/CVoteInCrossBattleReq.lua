local CVoteInCrossBattleReq = class("CVoteInCrossBattleReq")
CVoteInCrossBattleReq.TYPEID = 12616986
function CVoteInCrossBattleReq:ctor(activity_cfg_id, target_corps_id)
  self.id = 12616986
  self.activity_cfg_id = activity_cfg_id or nil
  self.target_corps_id = target_corps_id or nil
end
function CVoteInCrossBattleReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt64(self.target_corps_id)
end
function CVoteInCrossBattleReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.target_corps_id = os:unmarshalInt64()
end
function CVoteInCrossBattleReq:sizepolicy(size)
  return size <= 65535
end
return CVoteInCrossBattleReq
