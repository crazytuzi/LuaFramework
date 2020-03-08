local SSyncMyShoppingGroupList = class("SSyncMyShoppingGroupList")
SSyncMyShoppingGroupList.TYPEID = 12623631
function SSyncMyShoppingGroupList:ctor(list)
  self.id = 12623631
  self.list = list or {}
end
function SSyncMyShoppingGroupList:marshal(os)
  os:marshalCompactUInt32(table.getn(self.list))
  for _, v in ipairs(self.list) do
    v:marshal(os)
  end
end
function SSyncMyShoppingGroupList:unmarshal(os)
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.list, v)
  end
end
function SSyncMyShoppingGroupList:sizepolicy(size)
  return size <= 65535
end
return SSyncMyShoppingGroupList
