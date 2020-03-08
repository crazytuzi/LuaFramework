local SGetLoginSumAwardFailed = class("SGetLoginSumAwardFailed")
SGetLoginSumAwardFailed.TYPEID = 12604680
SGetLoginSumAwardFailed.ERROR_NOT_OPEN = -1
SGetLoginSumAwardFailed.ERROR_AWARD_HAVE_RECEIVED = -2
SGetLoginSumAwardFailed.ERROR_NOT_MATCH = -3
function SGetLoginSumAwardFailed:ctor(activityId, sortId, retcode)
  self.id = 12604680
  self.activityId = activityId or nil
  self.sortId = sortId or nil
  self.retcode = retcode or nil
end
function SGetLoginSumAwardFailed:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.sortId)
  os:marshalInt32(self.retcode)
end
function SGetLoginSumAwardFailed:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.sortId = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetLoginSumAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetLoginSumAwardFailed
