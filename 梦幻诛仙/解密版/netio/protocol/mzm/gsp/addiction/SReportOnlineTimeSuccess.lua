local SReportOnlineTimeSuccess = class("SReportOnlineTimeSuccess")
SReportOnlineTimeSuccess.TYPEID = 12608003
SReportOnlineTimeSuccess.ONLINE_TIME = 1
SReportOnlineTimeSuccess.TOTAL_ONLINE_TIME = 2
function SReportOnlineTimeSuccess:ctor(remind, remind_type, online_time, left_time)
  self.id = 12608003
  self.remind = remind or nil
  self.remind_type = remind_type or nil
  self.online_time = online_time or nil
  self.left_time = left_time or nil
end
function SReportOnlineTimeSuccess:marshal(os)
  os:marshalUInt8(self.remind)
  os:marshalInt32(self.remind_type)
  os:marshalInt32(self.online_time)
  os:marshalInt32(self.left_time)
end
function SReportOnlineTimeSuccess:unmarshal(os)
  self.remind = os:unmarshalUInt8()
  self.remind_type = os:unmarshalInt32()
  self.online_time = os:unmarshalInt32()
  self.left_time = os:unmarshalInt32()
end
function SReportOnlineTimeSuccess:sizepolicy(size)
  return size <= 65535
end
return SReportOnlineTimeSuccess
