local SSynJingjiData = class("SSynJingjiData")
SSynJingjiData.TYPEID = 12595716
function SSynJingjiData:ctor(winPoint, phase, totalbuycount, challengeCount, dayJifen, totalJifen, rank, isFirstVictoty, isFiveFight, lastSeasonPhase)
  self.id = 12595716
  self.winPoint = winPoint or nil
  self.phase = phase or nil
  self.totalbuycount = totalbuycount or nil
  self.challengeCount = challengeCount or nil
  self.dayJifen = dayJifen or nil
  self.totalJifen = totalJifen or nil
  self.rank = rank or nil
  self.isFirstVictoty = isFirstVictoty or nil
  self.isFiveFight = isFiveFight or nil
  self.lastSeasonPhase = lastSeasonPhase or nil
end
function SSynJingjiData:marshal(os)
  os:marshalInt32(self.winPoint)
  os:marshalInt32(self.phase)
  os:marshalInt32(self.totalbuycount)
  os:marshalInt32(self.challengeCount)
  os:marshalInt32(self.dayJifen)
  os:marshalInt64(self.totalJifen)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.isFirstVictoty)
  os:marshalInt32(self.isFiveFight)
  os:marshalInt32(self.lastSeasonPhase)
end
function SSynJingjiData:unmarshal(os)
  self.winPoint = os:unmarshalInt32()
  self.phase = os:unmarshalInt32()
  self.totalbuycount = os:unmarshalInt32()
  self.challengeCount = os:unmarshalInt32()
  self.dayJifen = os:unmarshalInt32()
  self.totalJifen = os:unmarshalInt64()
  self.rank = os:unmarshalInt32()
  self.isFirstVictoty = os:unmarshalInt32()
  self.isFiveFight = os:unmarshalInt32()
  self.lastSeasonPhase = os:unmarshalInt32()
end
function SSynJingjiData:sizepolicy(size)
  return size <= 65535
end
return SSynJingjiData
