local SGetPointRes = class("SGetPointRes")
SGetPointRes.TYPEID = 12591109
function SGetPointRes:ctor(addFrozenPoolNum, getingPoolPointNum, frozenPoolPointNum)
  self.id = 12591109
  self.addFrozenPoolNum = addFrozenPoolNum or nil
  self.getingPoolPointNum = getingPoolPointNum or nil
  self.frozenPoolPointNum = frozenPoolPointNum or nil
end
function SGetPointRes:marshal(os)
  os:marshalInt32(self.addFrozenPoolNum)
  os:marshalInt32(self.getingPoolPointNum)
  os:marshalInt32(self.frozenPoolPointNum)
end
function SGetPointRes:unmarshal(os)
  self.addFrozenPoolNum = os:unmarshalInt32()
  self.getingPoolPointNum = os:unmarshalInt32()
  self.frozenPoolPointNum = os:unmarshalInt32()
end
function SGetPointRes:sizepolicy(size)
  return size <= 32
end
return SGetPointRes
