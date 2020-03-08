local SManualRefreshError = class("SManualRefreshError")
SManualRefreshError.TYPEID = 12624910
SManualRefreshError.MONEY_NOT_ENOUGH = 1
SManualRefreshError.REFRESH_COUNT_MAX = 2
SManualRefreshError.NO_NEED_REFRESH = 3
SManualRefreshError.ACTIVITY_CLOSED = 4
SManualRefreshError.NOT_SUPPORTED = 5
SManualRefreshError.REFRESH_COUNT_ERROR = 6
SManualRefreshError.MALL_CLOSED = 7
function SManualRefreshError:ctor(errorCode, activityId, refreshCount)
  self.id = 12624910
  self.errorCode = errorCode or nil
  self.activityId = activityId or nil
  self.refreshCount = refreshCount or nil
end
function SManualRefreshError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.refreshCount)
end
function SManualRefreshError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
  self.refreshCount = os:unmarshalInt32()
end
function SManualRefreshError:sizepolicy(size)
  return size <= 65535
end
return SManualRefreshError
