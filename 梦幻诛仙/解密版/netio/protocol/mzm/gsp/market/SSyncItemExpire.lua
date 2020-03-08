local SSyncItemExpire = class("SSyncItemExpire")
SSyncItemExpire.TYPEID = 12601363
function SSyncItemExpire:ctor(marketId, itemId)
  self.id = 12601363
  self.marketId = marketId or nil
  self.itemId = itemId or nil
end
function SSyncItemExpire:marshal(os)
  os:marshalInt64(self.marketId)
  os:marshalInt32(self.itemId)
end
function SSyncItemExpire:unmarshal(os)
  self.marketId = os:unmarshalInt64()
  self.itemId = os:unmarshalInt32()
end
function SSyncItemExpire:sizepolicy(size)
  return size <= 65535
end
return SSyncItemExpire
