local CReqRefreshMysteryShopFree = class("CReqRefreshMysteryShopFree")
CReqRefreshMysteryShopFree.TYPEID = 12614407
function CReqRefreshMysteryShopFree:ctor(shoptype)
  self.id = 12614407
  self.shoptype = shoptype or nil
end
function CReqRefreshMysteryShopFree:marshal(os)
  os:marshalInt32(self.shoptype)
end
function CReqRefreshMysteryShopFree:unmarshal(os)
  self.shoptype = os:unmarshalInt32()
end
function CReqRefreshMysteryShopFree:sizepolicy(size)
  return size <= 65535
end
return CReqRefreshMysteryShopFree
