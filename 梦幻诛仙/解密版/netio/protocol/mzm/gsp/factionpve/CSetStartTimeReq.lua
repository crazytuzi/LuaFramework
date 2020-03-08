local CSetStartTimeReq = class("CSetStartTimeReq")
CSetStartTimeReq.TYPEID = 12613639
function CSetStartTimeReq:ctor(date, hour, minute)
  self.id = 12613639
  self.date = date or nil
  self.hour = hour or nil
  self.minute = minute or nil
end
function CSetStartTimeReq:marshal(os)
  os:marshalInt32(self.date)
  os:marshalInt32(self.hour)
  os:marshalInt32(self.minute)
end
function CSetStartTimeReq:unmarshal(os)
  self.date = os:unmarshalInt32()
  self.hour = os:unmarshalInt32()
  self.minute = os:unmarshalInt32()
end
function CSetStartTimeReq:sizepolicy(size)
  return size <= 65535
end
return CSetStartTimeReq
