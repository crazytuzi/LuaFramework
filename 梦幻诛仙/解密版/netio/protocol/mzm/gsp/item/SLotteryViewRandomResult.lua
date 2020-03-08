local SLotteryViewRandomResult = class("SLotteryViewRandomResult")
SLotteryViewRandomResult.TYPEID = 12584795
function SLotteryViewRandomResult:ctor(lotteryViewid, finalIndex, itemid, itemnum)
  self.id = 12584795
  self.lotteryViewid = lotteryViewid or nil
  self.finalIndex = finalIndex or nil
  self.itemid = itemid or nil
  self.itemnum = itemnum or nil
end
function SLotteryViewRandomResult:marshal(os)
  os:marshalInt32(self.lotteryViewid)
  os:marshalInt32(self.finalIndex)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemnum)
end
function SLotteryViewRandomResult:unmarshal(os)
  self.lotteryViewid = os:unmarshalInt32()
  self.finalIndex = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.itemnum = os:unmarshalInt32()
end
function SLotteryViewRandomResult:sizepolicy(size)
  return size <= 65535
end
return SLotteryViewRandomResult
