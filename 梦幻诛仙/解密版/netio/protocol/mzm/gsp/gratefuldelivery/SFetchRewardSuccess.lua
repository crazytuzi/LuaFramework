local SFetchRewardSuccess = class("SFetchRewardSuccess")
SFetchRewardSuccess.TYPEID = 12615683
function SFetchRewardSuccess:ctor(stage, activity_id)
  self.id = 12615683
  self.stage = stage or nil
  self.activity_id = activity_id or nil
end
function SFetchRewardSuccess:marshal(os)
  os:marshalInt32(self.stage)
  os:marshalInt32(self.activity_id)
end
function SFetchRewardSuccess:unmarshal(os)
  self.stage = os:unmarshalInt32()
  self.activity_id = os:unmarshalInt32()
end
function SFetchRewardSuccess:sizepolicy(size)
  return size <= 65535
end
return SFetchRewardSuccess
