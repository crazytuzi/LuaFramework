local SSynChildrenPotentialPointRes = class("SSynChildrenPotentialPointRes")
SSynChildrenPotentialPointRes.TYPEID = 12609404
function SSynChildrenPotentialPointRes:ctor(childrenid, potentialPoint)
  self.id = 12609404
  self.childrenid = childrenid or nil
  self.potentialPoint = potentialPoint or nil
end
function SSynChildrenPotentialPointRes:marshal(os)
  os:marshalInt64(self.childrenid)
  os:marshalInt32(self.potentialPoint)
end
function SSynChildrenPotentialPointRes:unmarshal(os)
  self.childrenid = os:unmarshalInt64()
  self.potentialPoint = os:unmarshalInt32()
end
function SSynChildrenPotentialPointRes:sizepolicy(size)
  return size <= 65535
end
return SSynChildrenPotentialPointRes
