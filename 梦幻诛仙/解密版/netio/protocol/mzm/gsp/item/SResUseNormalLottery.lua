local SResUseNormalLottery = class("SResUseNormalLottery")
SResUseNormalLottery.TYPEID = 12584781
function SResUseNormalLottery:ctor(lotteryItemid, finalItemid2num)
  self.id = 12584781
  self.lotteryItemid = lotteryItemid or nil
  self.finalItemid2num = finalItemid2num or {}
end
function SResUseNormalLottery:marshal(os)
  os:marshalInt32(self.lotteryItemid)
  local _size_ = 0
  for _, _ in pairs(self.finalItemid2num) do
    _size_ = _size_ + 1
  end
  os:marshalCompactUInt32(_size_)
  for k, v in pairs(self.finalItemid2num) do
    os:marshalInt32(k)
    os:marshalInt32(v)
  end
end
function SResUseNormalLottery:unmarshal(os)
  self.lotteryItemid = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local k = os:unmarshalInt32()
    local v = os:unmarshalInt32()
    self.finalItemid2num[k] = v
  end
end
function SResUseNormalLottery:sizepolicy(size)
  return size <= 65535
end
return SResUseNormalLottery
