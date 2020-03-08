local SGetBidRankError = class("SGetBidRankError")
SGetBidRankError.TYPEID = 12627211
SGetBidRankError.SERVER_LEVEL_LOW = 1
SGetBidRankError.ACTIVITY_CLOSE = 2
function SGetBidRankError:ctor(activityId, errorCode)
  self.id = 12627211
  self.activityId = activityId or nil
  self.errorCode = errorCode or nil
end
function SGetBidRankError:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.errorCode)
end
function SGetBidRankError:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.errorCode = os:unmarshalInt32()
end
function SGetBidRankError:sizepolicy(size)
  return size <= 65535
end
return SGetBidRankError
