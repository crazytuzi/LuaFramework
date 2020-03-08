local OctetsStream = require("netio.OctetsStream")
local MarketItem = class("MarketItem")
function MarketItem:ctor(marketId, itemId, price, restNum, sellNum, state, concernRoleNum, publicEndTime)
  self.marketId = marketId or nil
  self.itemId = itemId or nil
  self.price = price or nil
  self.restNum = restNum or nil
  self.sellNum = sellNum or nil
  self.state = state or nil
  self.concernRoleNum = concernRoleNum or nil
  self.publicEndTime = publicEndTime or nil
end
function MarketItem:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.price)
  os:marshalInt32(self.restNum)
  os:marshalInt32(self.sellNum)
  os:marshalInt32(self.state)
  os:marshalInt32(self.concernRoleNum)
  os:marshalInt64(self.publicEndTime)
end
function MarketItem:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.restNum = os:unmarshalInt32()
  self.sellNum = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
  self.concernRoleNum = os:unmarshalInt32()
  self.publicEndTime = os:unmarshalInt64()
end
return MarketItem
