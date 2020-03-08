local SApplyJoinDrawAndGuessSuccessRep = class("SApplyJoinDrawAndGuessSuccessRep")
SApplyJoinDrawAndGuessSuccessRep.TYPEID = 12617236
function SApplyJoinDrawAndGuessSuccessRep:ctor(timeStamp, sessionId)
  self.id = 12617236
  self.timeStamp = timeStamp or nil
  self.sessionId = sessionId or nil
end
function SApplyJoinDrawAndGuessSuccessRep:marshal(os)
  os:marshalInt64(self.timeStamp)
  os:marshalInt64(self.sessionId)
end
function SApplyJoinDrawAndGuessSuccessRep:unmarshal(os)
  self.timeStamp = os:unmarshalInt64()
  self.sessionId = os:unmarshalInt64()
end
function SApplyJoinDrawAndGuessSuccessRep:sizepolicy(size)
  return size <= 65535
end
return SApplyJoinDrawAndGuessSuccessRep
