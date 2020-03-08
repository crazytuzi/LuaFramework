local OctetsStream = require("netio.OctetsStream")
local MonthCardActivityInfo = class("MonthCardActivityInfo")
MonthCardActivityInfo.STATUS_NOT_PURCHASE = 1
MonthCardActivityInfo.STATUS_TODAY_IS_AWARDED = 2
MonthCardActivityInfo.STATUS_TODAY_NOT_AWARDED = 3
function MonthCardActivityInfo:ctor(phase, status, remain_days)
  self.phase = phase or nil
  self.status = status or nil
  self.remain_days = remain_days or nil
end
function MonthCardActivityInfo:marshal(os)
  os:marshalInt32(self.phase)
  os:marshalUInt8(self.status)
  os:marshalInt32(self.remain_days)
end
function MonthCardActivityInfo:unmarshal(os)
  self.phase = os:unmarshalInt32()
  self.status = os:unmarshalUInt8()
  self.remain_days = os:unmarshalInt32()
end
return MonthCardActivityInfo
