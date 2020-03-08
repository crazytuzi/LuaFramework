local SGetBackScoreAwardFail = class("SGetBackScoreAwardFail")
SGetBackScoreAwardFail.TYPEID = 12604423
SGetBackScoreAwardFail.ACTIVITY_CLOSE = 1
function SGetBackScoreAwardFail:ctor(result)
  self.id = 12604423
  self.result = result or nil
end
function SGetBackScoreAwardFail:marshal(os)
  os:marshalInt32(self.result)
end
function SGetBackScoreAwardFail:unmarshal(os)
  self.result = os:unmarshalInt32()
end
function SGetBackScoreAwardFail:sizepolicy(size)
  return size <= 65535
end
return SGetBackScoreAwardFail
