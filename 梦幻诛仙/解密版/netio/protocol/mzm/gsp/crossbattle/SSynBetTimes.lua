local SSynBetTimes = class("SSynBetTimes")
SSynBetTimes.TYPEID = 12617099
function SSynBetTimes:ctor(times)
  self.id = 12617099
  self.times = times or nil
end
function SSynBetTimes:marshal(os)
  os:marshalInt32(self.times)
end
function SSynBetTimes:unmarshal(os)
  self.times = os:unmarshalInt32()
end
function SSynBetTimes:sizepolicy(size)
  return size <= 65535
end
return SSynBetTimes
