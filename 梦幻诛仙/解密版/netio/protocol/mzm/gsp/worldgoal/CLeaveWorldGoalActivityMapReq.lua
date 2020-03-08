local CLeaveWorldGoalActivityMapReq = class("CLeaveWorldGoalActivityMapReq")
CLeaveWorldGoalActivityMapReq.TYPEID = 12594441
function CLeaveWorldGoalActivityMapReq:ctor(activity_cfg_id)
  self.id = 12594441
  self.activity_cfg_id = activity_cfg_id or nil
end
function CLeaveWorldGoalActivityMapReq:marshal(os)
  os:marshalInt32(self.activity_cfg_id)
end
function CLeaveWorldGoalActivityMapReq:unmarshal(os)
  self.activity_cfg_id = os:unmarshalInt32()
end
function CLeaveWorldGoalActivityMapReq:sizepolicy(size)
  return size <= 65535
end
return CLeaveWorldGoalActivityMapReq
