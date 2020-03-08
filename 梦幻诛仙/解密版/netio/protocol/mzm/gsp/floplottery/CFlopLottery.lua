local CFlopLottery = class("CFlopLottery")
CFlopLottery.TYPEID = 12618498
function CFlopLottery:ctor(uid, index, flopCount)
  self.id = 12618498
  self.uid = uid or nil
  self.index = index or nil
  self.flopCount = flopCount or nil
end
function CFlopLottery:marshal(os)
  os:marshalInt64(self.uid)
  os:marshalInt32(self.index)
  os:marshalInt32(self.flopCount)
end
function CFlopLottery:unmarshal(os)
  self.uid = os:unmarshalInt64()
  self.index = os:unmarshalInt32()
  self.flopCount = os:unmarshalInt32()
end
function CFlopLottery:sizepolicy(size)
  return size <= 65535
end
return CFlopLottery
