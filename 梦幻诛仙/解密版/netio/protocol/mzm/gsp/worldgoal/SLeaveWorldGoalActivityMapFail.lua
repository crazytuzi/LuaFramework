local SLeaveWorldGoalActivityMapFail = class("SLeaveWorldGoalActivityMapFail")
SLeaveWorldGoalActivityMapFail.TYPEID = 12594443
SLeaveWorldGoalActivityMapFail.NOT_IN_ACTIVITY_MAP = 1
SLeaveWorldGoalActivityMapFail.NO_TRANSFER_MAP_CFG_ID = 2
function SLeaveWorldGoalActivityMapFail:ctor(activity_cfg_id, res)
  self.id = 12594443
  self.activity_cfg_id = activity_cfg_id or nil
  self.res = res or nil
end
function SLeaveWorldGoalActivityMapFail:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.res)
end
function SLeaveWorldGoalActivityMapFail:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.res = os:unmarshalInt32()
end
function SLeaveWorldGoalActivityMapFail:sizepolicy(size)
  return size <= 65535
end
return SLeaveWorldGoalActivityMapFail
