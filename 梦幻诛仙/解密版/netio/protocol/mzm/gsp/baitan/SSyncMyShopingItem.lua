local SSyncMyShopingItem = class("SSyncMyShopingItem")
SSyncMyShopingItem.TYPEID = 12584987
function SSyncMyShopingItem:ctor(shopGridSize, MyShoppingItemList)
  self.id = 12584987
  self.shopGridSize = shopGridSize or nil
  self.MyShoppingItemList = MyShoppingItemList or {}
end
function SSyncMyShopingItem:marshal(os)
  os:marshalInt32(self.shopGridSize)
  os:marshalCompactUInt32(table.getn(self.MyShoppingItemList))
  for _, v in ipairs(self.MyShoppingItemList) do
    v:marshal(os)
  end
end
function SSyncMyShopingItem:unmarshal(os)
  self.shopGridSize = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.baitan.MyShoppingItem")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.MyShoppingItemList, v)
  end
end
function SSyncMyShopingItem:sizepolicy(size)
  return size <= 65535
end
return SSyncMyShopingItem
