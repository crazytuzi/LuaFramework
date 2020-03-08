local SOuterDrawError = class("SOuterDrawError")
SOuterDrawError.TYPEID = 12622861
SOuterDrawError.YUAN_BAO_NOT_ENOUGH = 1
SOuterDrawError.ITEM_NOT_ENOUGH = 2
SOuterDrawError.BAG_CAPACITY_NOT_ENOUGH = 3
SOuterDrawError.LAST_AWARD_NOT_RECEIVED = 4
function SOuterDrawError:ctor(errorCode, activityId)
  self.id = 12622861
  self.errorCode = errorCode or nil
  self.activityId = activityId or nil
end
function SOuterDrawError:marshal(os)
  os:marshalInt32(self.errorCode)
  os:marshalInt32(self.activityId)
end
function SOuterDrawError:unmarshal(os)
  self.errorCode = os:unmarshalInt32()
  self.activityId = os:unmarshalInt32()
end
function SOuterDrawError:sizepolicy(size)
  return size <= 65535
end
return SOuterDrawError
