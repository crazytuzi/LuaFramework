local SGetLoginSumAwardSuccess = class("SGetLoginSumAwardSuccess")
SGetLoginSumAwardSuccess.TYPEID = 12604673
function SGetLoginSumAwardSuccess:ctor(activityId, sortId)
  self.id = 12604673
  self.activityId = activityId or nil
  self.sortId = sortId or nil
end
function SGetLoginSumAwardSuccess:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.sortId)
end
function SGetLoginSumAwardSuccess:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.sortId = os:unmarshalInt32()
end
function SGetLoginSumAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetLoginSumAwardSuccess
