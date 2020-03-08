local CReqMysteryShopInfo = class("CReqMysteryShopInfo")
CReqMysteryShopInfo.TYPEID = 12614403
function CReqMysteryShopInfo:ctor(shoptype)
  self.id = 12614403
  self.shoptype = shoptype or nil
end
function CReqMysteryShopInfo:marshal(os)
  os:marshalInt32(self.shoptype)
end
function CReqMysteryShopInfo:unmarshal(os)
  self.shoptype = os:unmarshalInt32()
end
function CReqMysteryShopInfo:sizepolicy(size)
  return size <= 65535
end
return CReqMysteryShopInfo
