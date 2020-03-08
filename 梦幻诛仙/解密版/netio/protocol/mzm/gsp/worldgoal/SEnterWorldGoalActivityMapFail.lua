local SEnterWorldGoalActivityMapFail = class("SEnterWorldGoalActivityMapFail")
SEnterWorldGoalActivityMapFail.TYPEID = 12594442
SEnterWorldGoalActivityMapFail.CAN_NOT_JOIN_ACTIVITY = 1
SEnterWorldGoalActivityMapFail.CHECK_NPC_SERVICE_ERROR = 2
SEnterWorldGoalActivityMapFail.NO_TRANSFER_MAP_CFG_ID = 3
function SEnterWorldGoalActivityMapFail:ctor(activity_cfg_id, res)
  self.id = 12594442
  self.activity_cfg_id = activity_cfg_id or nil
  self.res = res or nil
end
function SEnterWorldGoalActivityMapFail:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.res)
end
function SEnterWorldGoalActivityMapFail:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SEnterWorldGoalActivityMapFail:sizepolicy(size)
  return size <= 65535
end
return SEnterWorldGoalActivityMapFail
