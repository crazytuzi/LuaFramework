local SSyncShopingList = class("SSyncShopingList")
SSyncShopingList.TYPEID = 12592646
function SSyncShopingList:ctor(shoppingItemList)
  self.id = 12592646
  self.shoppingItemList = shoppingItemList or {}
end
function SSyncShopingList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.shoppingItemList))
  for _, v in ipairs(self.shoppingItemList) do
    v:marshal(os)
  end
end
function SSyncShopingList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.shanghui.ShoppingItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.shoppingItemList, v)
  end
end
function SSyncShopingList:sizepolicy(size)
  return size <= 65535
end
return SSyncShopingList
