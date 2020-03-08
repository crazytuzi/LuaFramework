local SGetShoppingGroupListRes = class("SGetShoppingGroupListRes")
SGetShoppingGroupListRes.TYPEID = 12623632
function SGetShoppingGroupListRes:ctor(group_shopping_item_cfgid, page, last_page, shopping_groups)
  self.id = 12623632
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.page = page or nil
  self.last_page = last_page or nil
  self.shopping_groups = shopping_groups or {}
end
function SGetShoppingGroupListRes:marshal(os)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt32(self.page)
  os:marshalInt32(self.last_page)
  os:marshalCompactUInt32(table.getn(self.shopping_groups))
  for _, v in ipairs(self.shopping_groups) do
    v:marshal(os)
  end
end
function SGetShoppingGroupListRes:unmarshal(os)
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.page = os:unmarshalInt32()
  self.last_page = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.groupshopping.ShoppingGroupInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.shopping_groups, v)
  end
end
function SGetShoppingGroupListRes:sizepolicy(size)
  return size <= 65535
end
return SGetShoppingGroupListRes
