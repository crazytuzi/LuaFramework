local SSyncTreasureBoxActivityLeftTime = class("SSyncTreasureBoxActivityLeftTime")
SSyncTreasureBoxActivityLeftTime.TYPEID = 12587599
function SSyncTreasureBoxActivityLeftTime:ctor(startLeftTime, endLeftTime)
  self.id = 12587599
  self.startLeftTime = startLeftTime or nil
  self.endLeftTime = endLeftTime or nil
end
function SSyncTreasureBoxActivityLeftTime:marshal(os)
  os:marshalInt32(self.startLeftTime)
  os:marshalInt32(self.endLeftTime)
end
function SSyncTreasureBoxActivityLeftTime:unmarshal(os)
  self.startLeftTime = os:unmarshalInt32()
  self.endLeftTime = os:unmarshalInt32()
end
function SSyncTreasureBoxActivityLeftTime:sizepolicy(size)
  return size <= 65535
end
return SSyncTreasureBoxActivityLeftTime
