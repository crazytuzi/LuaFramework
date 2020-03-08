local SSyncBanShopingList = class("SSyncBanShopingList")
SSyncBanShopingList.TYPEID = 12592652
function SSyncBanShopingList:ctor(banItemList)
  self.id = 12592652
  self.banItemList = banItemList or {}
end
function SSyncBanShopingList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.banItemList))
  for _, v in ipairs(self.banItemList) do
    os:marshalInt32(v)
  end
end
function SSyncBanShopingList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local v = os:unmarshalInt32()
    table.insert(self.banItemList, v)
  end
end
function SSyncBanShopingList:sizepolicy(size)
  return size <= 65535
end
return SSyncBanShopingList
