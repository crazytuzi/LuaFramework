local SFrozenPointRes = class("SFrozenPointRes")
SFrozenPointRes.TYPEID = 12591108
function SFrozenPointRes:ctor(getingPoolPointNum)
  self.id = 12591108
  self.getingPoolPointNum = getingPoolPointNum or nil
end
function SFrozenPointRes:marshal(os)
  os:marshalInt32(self.getingPoolPointNum)
end
function SFrozenPointRes:unmarshal(os)
  self.getingPoolPointNum = os:unmarshalInt32()
end
function SFrozenPointRes:sizepolicy(size)
  return size <= 32
end
return SFrozenPointRes
