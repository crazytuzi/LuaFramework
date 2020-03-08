local SMarketItemPetBulletinRes = class("SMarketItemPetBulletinRes")
SMarketItemPetBulletinRes.TYPEID = 12601451
function SMarketItemPetBulletinRes:ctor(roleName, price, itemIdOrpetCfgId, pubOrsell, marketId)
  self.id = 12601451
  self.roleName = roleName or nil
  self.price = price or nil
  self.itemIdOrpetCfgId = itemIdOrpetCfgId or nil
  self.pubOrsell = pubOrsell or nil
  self.marketId = marketId or nil
end
function SMarketItemPetBulletinRes:marshal(os)
  os:marshalString(self.roleName)
  os:marshalInt32(self.price)
  os:marshalInt32(self.itemIdOrpetCfgId)
  os:marshalInt32(self.pubOrsell)
  os:marshalInt64(self.marketId)
end
function SMarketItemPetBulletinRes:unmarshal(os)
  self.roleName = os:unmarshalString()
  self.price = os:unmarshalInt32()
  self.itemIdOrpetCfgId = os:unmarshalInt32()
  self.pubOrsell = os:unmarshalInt32()
  self.marketId = os:unmarshalInt64()
end
function SMarketItemPetBulletinRes:sizepolicy(size)
  return size <= 65535
end
return SMarketItemPetBulletinRes
