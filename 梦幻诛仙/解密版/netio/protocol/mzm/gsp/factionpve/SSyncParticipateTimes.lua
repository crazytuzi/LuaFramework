local SSyncParticipateTimes = class("SSyncParticipateTimes")
SSyncParticipateTimes.TYPEID = 12613655
function SSyncParticipateTimes:ctor(participate_times, participate_millis, participate_faction)
  self.id = 12613655
  self.participate_times = participate_times or nil
  self.participate_millis = participate_millis or nil
  self.participate_faction = participate_faction or nil
end
function SSyncParticipateTimes:marshal(os)
  os:marshalInt32(self.participate_times)
  os:marshalInt64(self.participate_millis)
  os:marshalInt64(self.participate_faction)
end
function SSyncParticipateTimes:unmarshal(os)
  self.participate_times = os:unmarshalInt32()
  self.participate_millis = os:unmarshalInt64()
  self.participate_faction = os:unmarshalInt64()
end
function SSyncParticipateTimes:sizepolicy(size)
  return size <= 65535
end
return SSyncParticipateTimes
