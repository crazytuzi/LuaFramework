local SSynBigbossDataChanged = class("SSynBigbossDataChanged")
SSynBigbossDataChanged.TYPEID = 12598018
function SSynBigbossDataChanged:ctor(ocp, damagePoint, delta, rank, challengeCount)
  self.id = 12598018
  self.ocp = ocp or nil
  self.damagePoint = damagePoint or nil
  self.delta = delta or nil
  self.rank = rank or nil
  self.challengeCount = challengeCount or nil
end
function SSynBigbossDataChanged:marshal(os)
  os:marshalInt32(self.ocp)
  os:marshalInt32(self.damagePoint)
  os:marshalInt32(self.delta)
  os:marshalInt32(self.rank)
  os:marshalInt32(self.challengeCount)
end
function SSynBigbossDataChanged:unmarshal(os)
  self.ocp = os:unmarshalInt32()
  self.damagePoint = os:unmarshalInt32()
  self.delta = os:unmarshalInt32()
  self.rank = os:unmarshalInt32()
  self.challengeCount = os:unmarshalInt32()
end
function SSynBigbossDataChanged:sizepolicy(size)
  return size <= 65535
end
return SSynBigbossDataChanged
