local SUnlockGridRes = class("SUnlockGridRes")
SUnlockGridRes.TYPEID = 12584983
function SUnlockGridRes:ctor(gridSize)
  self.id = 12584983
  self.gridSize = gridSize or nil
end
function SUnlockGridRes:marshal(os)
  os:marshalInt32(self.gridSize)
end
function SUnlockGridRes:unmarshal(os)
  self.gridSize = os:unmarshalInt32()
end
function SUnlockGridRes:sizepolicy(size)
  return size <= 65535
end
return SUnlockGridRes
