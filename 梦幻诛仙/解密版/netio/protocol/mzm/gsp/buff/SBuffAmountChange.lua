local SBuffAmountChange = class("SBuffAmountChange")
SBuffAmountChange.TYPEID = 12583172
function SBuffAmountChange:ctor(buffId, buffCount)
  self.id = 12583172
  self.buffId = buffId or nil
  self.buffCount = buffCount or nil
end
function SBuffAmountChange:marshal(os)
  os:marshalInt32(self.buffId)
  os:marshalInt32(self.buffCount)
end
function SBuffAmountChange:unmarshal(os)
  self.buffId = os:unmarshalInt32()
  self.buffCount = os:unmarshalInt32()
end
function SBuffAmountChange:sizepolicy(size)
  return size <= 65535
end
return SBuffAmountChange
