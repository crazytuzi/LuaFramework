local CFetchRewardReq = class("CFetchRewardReq")
CFetchRewardReq.TYPEID = 12615692
function CFetchRewardReq:ctor(stage, activity_id)
  self.id = 12615692
  self.stage = stage or nil
  self.activity_id = activity_id or nil
end
function CFetchRewardReq:marshal(os)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.activity_id)
end
function CFetchRewardReq:unmarshal(os)
  self.stage = os:unmarshalInt32()
  self.activity_id = os:unmarshalInt32()
end
function CFetchRewardReq:sizepolicy(size)
  return size <= 65535
end
return CFetchRewardReq
