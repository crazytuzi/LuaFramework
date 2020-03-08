local SStartLotteryViewRes = class("SStartLotteryViewRes")
SStartLotteryViewRes.TYPEID = 12584841
function SStartLotteryViewRes:ctor(lotteryViewid, finalIndex, itemid, itemnum)
  self.id = 12584841
  self.lotteryViewid = lotteryViewid or nil
  self.finalIndex = finalIndex or nil
  self.itemid = itemid or nil
  self.itemnum = itemnum or nil
end
function SStartLotteryViewRes:marshal(os)
  os:marshalInt32(self.lotteryViewid)
  os:marshalInt32(self.finalIndex)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemnum)
end
function SStartLotteryViewRes:unmarshal(os)
  self.lotteryViewid = os:unmarshalInt32()
  self.finalIndex = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.itemnum = os:unmarshalInt32()
end
function SStartLotteryViewRes:sizepolicy(size)
  return size <= 65535
end
return SStartLotteryViewRes
