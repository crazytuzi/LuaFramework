local CGetMonthCardActivityAward = class("CGetMonthCardActivityAward")
CGetMonthCardActivityAward.TYPEID = 12588820
function CGetMonthCardActivityAward:ctor(activity_id)
  self.id = 12588820
  self.activity_id = activity_id or nil
end
function CGetMonthCardActivityAward:marshal(os)
  os:marshalInt32(self.activity_id)
end
function CGetMonthCardActivityAward:unmarshal(os)
  self.activity_id = os:unmarshalInt32()
end
function CGetMonthCardActivityAward:sizepolicy(size)
  return size <= 65535
end
return CGetMonthCardActivityAward
