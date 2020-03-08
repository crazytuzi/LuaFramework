local CGetShoppingGroupListReq = class("CGetShoppingGroupListReq")
CGetShoppingGroupListReq.TYPEID = 12623627
function CGetShoppingGroupListReq:ctor(group_shopping_item_cfgid, page)
  self.id = 12623627
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.page = page or nil
end
function CGetShoppingGroupListReq:marshal(os)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt32(self.page)
end
function CGetShoppingGroupListReq:unmarshal(os)
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.page = os:unmarshalInt32()
end
function CGetShoppingGroupListReq:sizepolicy(size)
  return size <= 65535
end
return CGetShoppingGroupListReq
