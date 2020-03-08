local SStageBrd = class("SStageBrd")
SStageBrd.TYPEID = 12612099
SStageBrd.STG_START_COUNTDOWN = 0
SStageBrd.STG_CARD = 1
SStageBrd.STG_FINISHED = 2
function SStageBrd:ctor(stage, end_millis)
  self.id = 12612099
  self.stage = stage or nil
  self.end_millis = end_millis or nil
end
function SStageBrd:marshal(os)
  os:marshalInt32(self.stage)
  os:marshalInt64(self.end_millis)
end
function SStageBrd:unmarshal(os)
  self.stage = os:unmarshalInt32()
  self.end_millis = os:unmarshalInt64()
end
function SStageBrd:sizepolicy(size)
  return size <= 65535
end
return SStageBrd
