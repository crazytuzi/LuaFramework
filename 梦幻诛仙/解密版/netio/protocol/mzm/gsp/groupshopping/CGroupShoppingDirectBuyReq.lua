local CGroupShoppingDirectBuyReq = class("CGroupShoppingDirectBuyReq")
CGroupShoppingDirectBuyReq.TYPEID = 12623633
function CGroupShoppingDirectBuyReq:ctor(group_shopping_item_cfgid, current_yuanbao)
  self.id = 12623633
  self.group_shopping_item_cfgid = group_shopping_item_cfgid or nil
  self.current_yuanbao = current_yuanbao or nil
end
function CGroupShoppingDirectBuyReq:marshal(os)
  os:marshalInt32(self.group_shopping_item_cfgid)
  os:marshalInt64(self.current_yuanbao)
end
function CGroupShoppingDirectBuyReq:unmarshal(os)
  self.group_shopping_item_cfgid = os:unmarshalInt32()
  self.current_yuanbao = os:unmarshalInt64()
end
function CGroupShoppingDirectBuyReq:sizepolicy(size)
  return size <= 65535
end
return CGroupShoppingDirectBuyReq
