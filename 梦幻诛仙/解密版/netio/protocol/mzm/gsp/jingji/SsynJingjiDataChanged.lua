local SsynJingjiDataChanged = class("SsynJingjiDataChanged")
SsynJingjiDataChanged.TYPEID = 12595722
function SsynJingjiDataChanged:ctor(iswin, winPoint, winPointDelta, phase, challengeCount, dayJifen, totalJifen, rank)
  self.id = 12595722
  self.iswin = iswin or nil
  self.winPoint = winPoint or nil
  self.winPointDelta = winPointDelta or nil
  self.phase = phase or nil
  self.challengeCount = challengeCount or nil
  self.dayJifen = dayJifen or nil
  self.totalJifen = totalJifen or nil
  self.rank = rank or nil
end
function SsynJingjiDataChanged:marshal(os)
  os:marshalInt32(self.iswin)
  os:marshalInt32(self.winPoint)
  os:marshalInt32(self.winPointDelta)
  os:marshalInt32(self.phase)
  os:marshalInt32(self.challengeCount)
  os:marshalInt32(self.dayJifen)
  os:marshalInt64(self.totalJifen)
  os:marshalInt32(self.rank)
end
function SsynJingjiDataChanged:unmarshal(os)
  self.iswin = os:unmarshalInt32()
  self.winPoint = os:unmarshalInt32()
  self.winPointDelta = os:unmarshalInt32()
  self.phase = os:unmarshalInt32()
  self.challengeCount = os:unmarshalInt32()
  self.dayJifen = os:unmarshalInt32()
  self.totalJifen = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
end
function SsynJingjiDataChanged:sizepolicy(size)
  return size <= 65535
end
return SsynJingjiDataChanged
