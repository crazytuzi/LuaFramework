local SInnerDrawError = class("SInnerDrawError")
SInnerDrawError.TYPEID = 12622849
SInnerDrawError.TICKET_NOT_ENOUGH = 1
SInnerDrawError.BAG_CAPACITY_NOT_ENOUGH = 2
SInnerDrawError.LAST_AWARD_NOT_RECEIVED = 3
function SInnerDrawError:ctor(activityId, errorCode)
  self.id = 12622849
  self.activityId = activityId or nil
  self.errorCode = errorCode or nil
end
function SInnerDrawError:marshal(os)
  os:marshalInt32(self.activityId)
  os:marshalInt32(self.errorCode)
end
function SInnerDrawError:unmarshal(os)
  self.activityId = os:unmarshalInt32()
  self.errorCode = os:unmarshalInt32()
end
function SInnerDrawError:sizepolicy(size)
  return size <= 65535
end
return SInnerDrawError
