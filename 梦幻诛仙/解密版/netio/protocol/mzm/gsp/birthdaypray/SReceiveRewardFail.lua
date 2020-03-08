local SReceiveRewardFail = class("SReceiveRewardFail")
SReceiveRewardFail.TYPEID = 12623107
SReceiveRewardFail.ERROR_SYSTEM = 1
SReceiveRewardFail.ERROR_USERID = 2
SReceiveRewardFail.ERROR_CFG = 3
SReceiveRewardFail.ERROR_PARAM = 4
SReceiveRewardFail.ERROR_ACTIVITY_CLOSED = 5
SReceiveRewardFail.ERROR_TIMES_NOT_ENOUGH = 6
SReceiveRewardFail.ERROR_RECEIVED_ALREADY = 7
SReceiveRewardFail.ERROR_BAG_FULL = 8
function SReceiveRewardFail:ctor(activity_cfg_id, task_activity_id, stage_id, error_code)
  self.id = 12623107
  self.activity_cfg_id = activity_cfg_id or nil
  self.task_activity_id = task_activity_id or nil
  self.stage_id = stage_id or nil
  self.error_code = error_code or nil
end
function SReceiveRewardFail:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.task_activity_id)
  os:marshalInt32(self.stage_id)
  os:marshalInt32(self.error_code)
end
function SReceiveRewardFail:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.task_activity_id = os:unmarshalInt32()
  self.stage_id = os:unmarshalInt32()
  self.error_code = os:unmarshalInt32()
end
function SReceiveRewardFail:sizepolicy(size)
  return size <= 65535
end
return SReceiveRewardFail
