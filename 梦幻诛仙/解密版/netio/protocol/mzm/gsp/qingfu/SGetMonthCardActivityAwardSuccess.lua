local SGetMonthCardActivityAwardSuccess = class("SGetMonthCardActivityAwardSuccess")
SGetMonthCardActivityAwardSuccess.TYPEID = 12588817
function SGetMonthCardActivityAwardSuccess:ctor(activity_id)
  self.id = 12588817
  self.activity_id = activity_id or nil
end
function SGetMonthCardActivityAwardSuccess:marshal(os)
  os:marshalInt32(self.activity_id)
end
function SGetMonthCardActivityAwardSuccess:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
end
function SGetMonthCardActivityAwardSuccess:sizepolicy(size)
  return size <= 65535
end
return SGetMonthCardActivityAwardSuccess
