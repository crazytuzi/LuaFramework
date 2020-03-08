local SGetMonthCardActivityAwardFailed = class("SGetMonthCardActivityAwardFailed")
SGetMonthCardActivityAwardFailed.TYPEID = 12588818
SGetMonthCardActivityAwardFailed.ERROR_NOT_PURCHASE = -1
SGetMonthCardActivityAwardFailed.ERROR_REMAIN_DAYS = -2
SGetMonthCardActivityAwardFailed.ERROR_ALREADY_GET_AWARD = -3
function SGetMonthCardActivityAwardFailed:ctor(activity_id, retcode)
  self.id = 12588818
  self.activity_id = activity_id or nil
  self.retcode = retcode or nil
end
function SGetMonthCardActivityAwardFailed:marshal(os)
  os:marshalInt32(self.activity_id)
  os:marshalInt32(self.retcode)
end
function SGetMonthCardActivityAwardFailed:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
  self.retcode = os:unmarshalInt32()
end
function SGetMonthCardActivityAwardFailed:sizepolicy(size)
  return size <= 65535
end
return SGetMonthCardActivityAwardFailed
