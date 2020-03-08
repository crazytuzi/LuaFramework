local SSynRoleConcernInfo = class("SSynRoleConcernInfo")
SSynRoleConcernInfo.TYPEID = 12601368
function SSynRoleConcernInfo:ctor(marketItemList, marketPetList)
  self.id = 12601368
  self.marketItemList = marketItemList or {}
  self.marketPetList = marketPetList or {}
end
function SSynRoleConcernInfo:marshal(os)
  os:marshalCompactUInt32(table.getn(self.marketItemList))
  for _, v in ipairs(self.marketItemList) do
    v:marshal(os)
  end
  os:marshalCompactUInt32(table.getn(self.marketPetList))
  for _, v in ipairs(self.marketPetList) do
    v:marshal(os)
  end
end
function SSynRoleConcernInfo:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.MarketItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.marketItemList, v)
  end
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.market.MarketPet")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.marketPetList, v)
  end
end
function SSynRoleConcernInfo:sizepolicy(size)
  return size <= 65535
end
return SSynRoleConcernInfo
