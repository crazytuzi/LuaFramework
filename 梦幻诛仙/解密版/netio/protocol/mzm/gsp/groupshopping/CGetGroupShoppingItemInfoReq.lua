local CGetGroupShoppingItemInfoReq = class("CGetGroupShoppingItemInfoReq")
CGetGroupShoppingItemInfoReq.TYPEID = 12623624
function CGetGroupShoppingItemInfoReq:ctor(group_shopping_item_cfgid)
  self.id = 12623624
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
end
function CGetGroupShoppingItemInfoReq:marshal(os)
  os:marshalInt32(self.group_shopping_item_cfgid)
end
function CGetGroupShoppingItemInfoReq:unmarshal(os)
  self.group_shopping_item_cfgid = os:unmarshalInt32()
end
function CGetGroupShoppingItemInfoReq:sizepolicy(size)
  return size <= 65535
end
return CGetGroupShoppingItemInfoReq
