local SsynRewardChanged = class("SsynRewardChanged")
SsynRewardChanged.TYPEID = 12595720
function SsynRewardChanged:ctor(isFirstVictoty, isFiveFight, lastSeasonPhase)
  self.id = 12595720
  self.isFirstVictoty = isFirstVictoty or nil
  self.isFiveFight = isFiveFight or nil
  self.lastSeasonPhase = lastSeasonPhase or nil
end
function SsynRewardChanged:marshal(os)
  os:marshalInt32(self.isFirstVictoty)
  os:marshalInt32(self.isFiveFight)
  os:marshalInt32(self.lastSeasonPhase)
end
function SsynRewardChanged:unmarshal(os)
  self.isFirstVictoty = os:unmarshalInt32()
  self.isFiveFight = os:unmarshalInt32()
  self.lastSeasonPhase = os:unmarshalInt32()
end
function SsynRewardChanged:sizepolicy(size)
  return size <= 65535
end
return SsynRewardChanged
