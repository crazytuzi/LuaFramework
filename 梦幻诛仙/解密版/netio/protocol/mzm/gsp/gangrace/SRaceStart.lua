local SRaceStart = class("SRaceStart")
SRaceStart.TYPEID = 12602125
function SRaceStart:ctor(curCount, maxCount)
  self.id = 12602125
  self.curCount = curCount or nil
  self.maxCount = maxCount or nil
end
function SRaceStart:marshal(os)
  os:marshalInt32(self.curCount)
  os:marshalInt32(self.maxCount)
end
function SRaceStart:unmarshal(os)
  self.curCount = os:unmarshalInt32()
  self.maxCount = os:unmarshalInt32()
end
function SRaceStart:sizepolicy(size)
  return size <= 65535
end
return SRaceStart
