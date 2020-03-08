local SGetLoginAwardFailed = class("SGetLoginAwardFailed")
SGetLoginAwardFailed.TYPEID = 12604675
SGetLoginAwardFailed.ERROR_NOT_OPEN = -1
SGetLoginAwardFailed.ERROR_AWARD_HAVE_RECEIVED = -2
SGetLoginAwardFailed.ERROR_NOT_MATCH = -3
SGetLoginAwardFailed.ERROR_AWARD_MISS = -4
function SGetLoginAwardFailed:ctor(activityId, sortId, retcode)
  self.id = 12604675
  self.activityId = activityId or nil
  self.sortId = sortId or nil
  self.retcode = retcode or nil
end
function SGetLoginAwardFailed:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.sortId)
  os:marshalInt32(self.retcode)
end
function SGetLoginAwardFailed:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.sortId = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetLoginAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetLoginAwardFailed
