local SyncExchangeScore = class("SyncExchangeScore")
SyncExchangeScore.TYPEID = 12607497
function SyncExchangeScore:ctor(score)
  self.id = 12607497
  self.score = score or nil
end
function SyncExchangeScore:marshal(os)
  os:marshalInt32(self.score)
end
function SyncExchangeScore:unmarshal(os)
  self.score = os:unmarshalInt32()
end
function SyncExchangeScore:sizepolicy(size)
  return size <= 65535
end
return SyncExchangeScore
