local SNotifyDrawAndGuessInvite = class("SNotifyDrawAndGuessInvite")
SNotifyDrawAndGuessInvite.TYPEID = 12617233
function SNotifyDrawAndGuessInvite:ctor(timeStamp, sessionId)
  self.id = 12617233
  self.timeStamp = timeStamp or nil
  self.sessionId = sessionId or nil
end
function SNotifyDrawAndGuessInvite:marshal(os)
  os:marshalInt64(self.timeStamp)
  os:marshalInt64(self.sessionId)
end
function SNotifyDrawAndGuessInvite:unmarshal(os)
  self.timeStamp = os:unmarshalInt64()
  self.sessionId = os:unmarshalInt64()
end
function SNotifyDrawAndGuessInvite:sizepolicy(size)
  return size <= 65535
end
return SNotifyDrawAndGuessInvite
