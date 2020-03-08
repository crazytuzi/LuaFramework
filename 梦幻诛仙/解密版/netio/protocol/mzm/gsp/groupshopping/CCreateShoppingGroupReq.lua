local CCreateShoppingGroupReq = class("CCreateShoppingGroupReq")
CCreateShoppingGroupReq.TYPEID = 12623636
function CCreateShoppingGroupReq:ctor(group_shopping_item_cfgid, current_yuanbao)
  self.id = 12623636
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.current_yuanbao = current_yuanbao or nil
end
function CCreateShoppingGroupReq:marshal(os)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt64(self.current_yuanbao)
end
function CCreateShoppingGroupReq:unmarshal(os)
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.current_yuanbao = os:unmarshalInt64()
end
function CCreateShoppingGroupReq:sizepolicy(size)
  return size <= 65535
end
return CCreateShoppingGroupReq
