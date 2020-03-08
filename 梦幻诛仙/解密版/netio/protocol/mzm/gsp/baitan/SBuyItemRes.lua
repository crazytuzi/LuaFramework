local SBuyItemRes = class("SBuyItemRes")
SBuyItemRes.TYPEID = 12584968
SBuyItemRes.SUCCESS = 0
SBuyItemRes.ALL_SELLED = 1
SBuyItemRes.NOT_IN_SELL = 3
function SBuyItemRes:ctor(buy_res, index, itemid, num, price, useMoney)
  self.id = 12584968
  self.buy_res = buy_res or nil
  self.index = index or nil
  self.itemid = itemid or nil
  self.num = num or nil
  self.price = price or nil
  self.useMoney = useMoney or nil
end
function SBuyItemRes:marshal(os)
  os:marshalInt32(self.buy_res)
  os:marshalInt32(self.index)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.num)
  os:marshalInt32(self.price)
  os:marshalInt32(self.useMoney)
end
function SBuyItemRes:unmarshal(os)
  self.buy_res = os:unmarshalInt32()
  self.index = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.useMoney = os:unmarshalInt32()
end
function SBuyItemRes:sizepolicy(size)
  return size <= 65535
end
return SBuyItemRes
