local CBuyMysteryGoodsReq = class("CBuyMysteryGoodsReq")
CBuyMysteryGoodsReq.TYPEID = 12614406
function CBuyMysteryGoodsReq:ctor(shoptype, goods_index, goods_id, count, client_cost_type, client_cost_num)
  self.id = 12614406
  self.shoptype = shoptype or nil
  self.goods_index = goods_index or nil
  self.goods_id = goods_id or nil
  self.count = count or nil
  self.client_cost_type = client_cost_type or nil
  self.client_cost_num = client_cost_num or nil
end
function CBuyMysteryGoodsReq:marshal(os)
  os:marshalInt32(self.shoptype)
  os:marshalInt32(self.goods_index)
  os:marshalInt32(self.goods_id)
  os:marshalInt32(self.count)
  os:marshalInt32(self.client_cost_type)
  os:marshalInt64(self.client_cost_num)
end
function CBuyMysteryGoodsReq:unmarshal(os)
  self.shoptype = os:unmarshalInt32()
  self.goods_index = os:unmarshalInt32()
  self.goods_id = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
  self.client_cost_type = os:unmarshalInt32()
  self.client_cost_num = os:unmarshalInt64()
end
function CBuyMysteryGoodsReq:sizepolicy(size)
  return size <= 65535
end
return CBuyMysteryGoodsReq
