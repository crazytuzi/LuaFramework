local SSynCrossFieldForbidMatchInfo = class("SSynCrossFieldForbidMatchInfo")
SSynCrossFieldForbidMatchInfo.TYPEID = 12619530
function SSynCrossFieldForbidMatchInfo:ctor(active_leave_field_timestamp)
  self.id = 12619530
  self.active_leave_field_timestamp = active_leave_field_timestamp or nil
end
function SSynCrossFieldForbidMatchInfo:marshal(os)
  os:marshalInt32(self.active_leave_field_timestamp)
end
function SSynCrossFieldForbidMatchInfo:unmarshal(os)
  self.active_leave_field_timestamp = os:unmarshalInt32()
end
function SSynCrossFieldForbidMatchInfo:sizepolicy(size)
  return size <= 65535
end
return SSynCrossFieldForbidMatchInfo
