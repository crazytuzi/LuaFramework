local SCoupleDailyPinTuStart = class("SCoupleDailyPinTuStart")
SCoupleDailyPinTuStart.TYPEID = 12602372
function SCoupleDailyPinTuStart:ctor(sessionId)
  self.id = 12602372
  self.sessionId = sessionId or nil
end
function SCoupleDailyPinTuStart:marshal(os)
  os:marshalInt64(self.sessionId)
end
function SCoupleDailyPinTuStart:unmarshal(os)
  self.sessionId = os:unmarshalInt64()
end
function SCoupleDailyPinTuStart:sizepolicy(size)
  return size <= 65535
end
return SCoupleDailyPinTuStart
