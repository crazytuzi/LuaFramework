local SSynBigbossData = class("SSynBigbossData")
SSynBigbossData.TYPEID = 12598017
function SSynBigbossData:ctor(damagePoint, ocp, rank, totalbuycount, challengeCount, monsterid, nextmonsterid, startTime, endTime, nextStartTime)
  self.id = 12598017
  self.damagePoint = damagePoint or nil
  self.ocp = ocp or nil
  self.rank = rank or nil
  self.totalbuycount = totalbuycount or nil
  self.challengeCount = challengeCount or nil
  self.monsterid = monsterid or nil
  self.nextmonsterid = nextmonsterid or nil
  self.startTime = startTime or nil
  self.endTime = endTime or nil
  self.nextStartTime = nextStartTime or nil
end
function SSynBigbossData:marshal(os)
  os:marshalInt32(self.damagePoint)
  os:marshalInt32(self.ocp)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.totalbuycount)
  os:marshalInt32(self.challengeCount)
  os:marshalInt32(self.monsterid)
  os:marshalInt32(self.nextmonsterid)
  os:marshalInt64(self.startTime)
  os:marshalInt64(self.endTime)
  os:marshalInt64(self.nextStartTime)
end
function SSynBigbossData:unmarshal(os)
  self.damagePoint = os:unmarshalInt32()
  self.ocp = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.totalbuycount = os:unmarshalInt32()
  self.challengeCount = os:unmarshalInt32()
  self.monsterid = os:unmarshalInt32()
  self.nextmonsterid = os:unmarshalInt32()
  self.startTime = os:unmarshalInt64()
  self.endTime = os:unmarshalInt64()
  self.nextStartTime = os:unmarshalInt64()
end
function SSynBigbossData:sizepolicy(size)
  return size <= 65535
end
return SSynBigbossData
