local SSyncStartTime = class("SSyncStartTime")
SSyncStartTime.TYPEID = 12613644
function SSyncStartTime:ctor(start_time)
  self.id = 12613644
  self.start_time = start_time or nil
end
function SSyncStartTime:marshal(os)
  os:marshalInt64(self.start_time)
end
function SSyncStartTime:unmarshal(os)
  self.start_time = os:unmarshalInt64()
end
function SSyncStartTime:sizepolicy(size)
  return size <= 65535
end
return SSyncStartTime
