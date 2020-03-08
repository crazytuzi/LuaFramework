local SResUseTurntableItemLottery = class("SResUseTurntableItemLottery")
SResUseTurntableItemLottery.TYPEID = 12584783
function SResUseTurntableItemLottery:ctor(lotteryItemid, itemids, finalIndex)
  self.id = 12584783
  self.lotteryItemid = lotteryItemid or nil
  self.itemids = itemids or {}
  self.finalIndex = finalIndex or nil
end
function SResUseTurntableItemLottery:marshal(os)
  os:marshalInt32(self.lotteryItemid)
  os:marshalCompactUInt32(table.getn(self.itemids))
  for _, v in ipairs(self.itemids) do
    os:marshalInt32(v)
  end
  os:marshalInt32(self.finalIndex)
end
function SResUseTurntableItemLottery:unmarshal(os)
  self.lotteryItemid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.itemids, v)
  end
  self.finalIndex = os:unmarshalInt32()
end
function SResUseTurntableItemLottery:sizepolicy(size)
  return size <= 65535
end
return SResUseTurntableItemLottery
