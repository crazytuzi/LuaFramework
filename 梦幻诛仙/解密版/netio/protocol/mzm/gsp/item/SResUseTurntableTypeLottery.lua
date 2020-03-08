local SResUseTurntableTypeLottery = class("SResUseTurntableTypeLottery")
SResUseTurntableTypeLottery.TYPEID = 12584782
function SResUseTurntableTypeLottery:ctor(lotteryItemid, finalIndex, itemid, itemnum, exptype, expnum, moneytype, moneynum)
  self.id = 12584782
  self.lotteryItemid = lotteryItemid or nil
  self.finalIndex = finalIndex or nil
  self.itemid = itemid or nil
  self.itemnum = itemnum or nil
  self.exptype = exptype or nil
  self.expnum = expnum or nil
  self.moneytype = moneytype or nil
  self.moneynum = moneynum or nil
end
function SResUseTurntableTypeLottery:marshal(os)
  os:marshalInt32(self.lotteryItemid)
  os:marshalInt32(self.finalIndex)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemnum)
  os:marshalInt32(self.exptype)
  os:marshalInt32(self.expnum)
  os:marshalInt32(self.moneytype)
  os:marshalInt32(self.moneynum)
end
function SResUseTurntableTypeLottery:unmarshal(os)
  self.lotteryItemid = os:unmarshalInt32()
  self.finalIndex = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.itemnum = os:unmarshalInt32()
  self.exptype = os:unmarshalInt32()
  self.expnum = os:unmarshalInt32()
  self.moneytype = os:unmarshalInt32()
  self.moneynum = os:unmarshalInt32()
end
function SResUseTurntableTypeLottery:sizepolicy(size)
  return size <= 65535
end
return SResUseTurntableTypeLottery
