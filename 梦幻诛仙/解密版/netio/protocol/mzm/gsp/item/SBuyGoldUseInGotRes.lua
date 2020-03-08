local SBuyGoldUseInGotRes = class("SBuyGoldUseInGotRes")
SBuyGoldUseInGotRes.TYPEID = 12584843
function SBuyGoldUseInGotRes:ctor(inGotNum, buyGoldNum)
  self.id = 12584843
  self.inGotNum = inGotNum or nil
  self.buyGoldNum = buyGoldNum or nil
end
function SBuyGoldUseInGotRes:marshal(os)
  os:marshalInt32(self.inGotNum)
  os:marshalInt32(self.buyGoldNum)
end
function SBuyGoldUseInGotRes:unmarshal(os)
  self.inGotNum = os:unmarshalInt32()
  self.buyGoldNum = os:unmarshalInt32()
end
function SBuyGoldUseInGotRes:sizepolicy(size)
  return size <= 65535
end
return SBuyGoldUseInGotRes
