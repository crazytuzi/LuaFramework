local CReqRefreshMysteryShop = class("CReqRefreshMysteryShop")
CReqRefreshMysteryShop.TYPEID = 12614405
function CReqRefreshMysteryShop:ctor(shoptype, client_cost_type, client_cost_num)
  self.id = 12614405
  self.shoptype = shoptype or nil
  self.client_cost_type = client_cost_type or nil
  self.client_cost_num = client_cost_num or nil
end
function CReqRefreshMysteryShop:marshal(os)
  os:marshalInt32(self.shoptype)
  os:marshalInt32(self.client_cost_type)
  os:marshalInt64(self.client_cost_num)
end
function CReqRefreshMysteryShop:unmarshal(os)
  self.shoptype = os:unmarshalInt32()
  self.client_cost_type = os:unmarshalInt32()
  self.client_cost_num = os:unmarshalInt64()
end
function CReqRefreshMysteryShop:sizepolicy(size)
  return size <= 65535
end
return CReqRefreshMysteryShop
