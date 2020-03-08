local SGetBackScoreAwardInfo = class("SGetBackScoreAwardInfo")
SGetBackScoreAwardInfo.TYPEID = 12604425
function SGetBackScoreAwardInfo:ctor(exp_value, silver_value)
  self.id = 12604425
  self.exp_value = exp_value or nil
  self.silver_value = silver_value or nil
end
function SGetBackScoreAwardInfo:marshal(os)
  os:marshalInt32(self.exp_value)
  os:marshalInt64(self.silver_value)
end
function SGetBackScoreAwardInfo:unmarshal(os)
  self.exp_value = os:unmarshalInt32()
  self.silver_value = os:unmarshalInt64()
end
function SGetBackScoreAwardInfo:sizepolicy(size)
  return size <= 65535
end
return SGetBackScoreAwardInfo
