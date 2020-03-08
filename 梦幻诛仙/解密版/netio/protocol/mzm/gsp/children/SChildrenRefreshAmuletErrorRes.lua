local SChildrenRefreshAmuletErrorRes = class("SChildrenRefreshAmuletErrorRes")
SChildrenRefreshAmuletErrorRes.TYPEID = 12609414
SChildrenRefreshAmuletErrorRes.ERROR_ITEM_NOT_ENOUGH = 1
SChildrenRefreshAmuletErrorRes.ERROR_ITEM_NOT_SUIT = 2
SChildrenRefreshAmuletErrorRes.ERROR_POS_DO_NOT_HAS_EQUIP = 3
SChildrenRefreshAmuletErrorRes.ERROR_YUANBAO_NOT_ENOUGH = 4
SChildrenRefreshAmuletErrorRes.ERROR_ITEM_PRICE_CHANGED = 5
function SChildrenRefreshAmuletErrorRes:ctor(ret)
  self.id = 12609414
  self.ret = ret or nil
end
function SChildrenRefreshAmuletErrorRes:marshal(os)
  os:marshalInt32(self.ret)
end
function SChildrenRefreshAmuletErrorRes:unmarshal(os)
  self.ret = os:unmarshalInt32()
end
function SChildrenRefreshAmuletErrorRes:sizepolicy(size)
  return size <= 65535
end
return SChildrenRefreshAmuletErrorRes
