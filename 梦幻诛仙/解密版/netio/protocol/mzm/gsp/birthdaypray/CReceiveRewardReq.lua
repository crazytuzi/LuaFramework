local CReceiveRewardReq = class("CReceiveRewardReq")
CReceiveRewardReq.TYPEID = 12623105
function CReceiveRewardReq:ctor(activity_cfg_id, task_activity_id, stage_id)
  self.id = 12623105
  self.activity_cfg_id = activity_cfg_id or nil
  self.task_activity_id = task_activity_id or nil
  self.stage_id = stage_id or nil
end
function CReceiveRewardReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
  os:marshalInt32(self.task_activity_id)
  os:marshalInt32(self.stage_id)
end
function CReceiveRewardReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
  self.task_activity_id = os:unmarshalInt32()
  self.stage_id = os:unmarshalInt32()
end
function CReceiveRewardReq:sizepolicy(size)
  return size <= 65535
end
return CReceiveRewardReq
