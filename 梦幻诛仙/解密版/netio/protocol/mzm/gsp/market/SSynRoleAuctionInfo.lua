local SSynRoleAuctionInfo = class("SSynRoleAuctionInfo")
SSynRoleAuctionInfo.TYPEID = 12601424
function SSynRoleAuctionInfo:ctor(marketItemList, marketPetList)
  self.id = 12601424
  self.marketItemList = marketItemList or {}
  self.marketPetList = marketPetList or {}
end
function SSynRoleAuctionInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.marketItemList))
  for _, v in ipairs(self.marketItemList) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.marketPetList))
  for _, v in ipairs(self.marketPetList) do
    v:marshal(os)
  end
end
function SSynRoleAuctionInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.AuctionItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.marketItemList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.AuctionPet")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.marketPetList, v)
  end
end
function SSynRoleAuctionInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleAuctionInfo
