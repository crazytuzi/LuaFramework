local SBuyGoodsSuccess = class("SBuyGoodsSuccess")
SBuyGoodsSuccess.TYPEID = 12621316
function SBuyGoodsSuccess:ctor(cfgId, buyCount)
  self.id = 12621316
  self.cfgId = cfgId or nil
  self.buyCount = buyCount or nil
end
function SBuyGoodsSuccess:marshal(os)
  os:marshalInt32(self.cfgId)
  os:marshalInt32(self.buyCount)
end
function SBuyGoodsSuccess:unmarshal(os)
  self.cfgId = os:unmarshalInt32()
  self.buyCount = os:unmarshalInt32()
end
function SBuyGoodsSuccess:sizepolicy(size)
  return size <= 65535
end
return SBuyGoodsSuccess
