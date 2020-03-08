local SMysteryGoodsChangeInfo = class("SMysteryGoodsChangeInfo")
SMysteryGoodsChangeInfo.TYPEID = 12614401
function SMysteryGoodsChangeInfo:ctor(shoptype, goods_index, goods_id, count)
  self.id = 12614401
  self.shoptype = shoptype or nil
  self.goods_index = goods_index or nil
  self.goods_id = goods_id or nil
  self.count = count or nil
end
function SMysteryGoodsChangeInfo:marshal(os)
  os:marshalInt32(self.shoptype)
  os:marshalInt32(self.goods_index)
  os:marshalInt32(self.goods_id)
  os:marshalInt32(self.count)
end
function SMysteryGoodsChangeInfo:unmarshal(os)
  self.shoptype = os:unmarshalInt32()
  self.goods_index = os:unmarshalInt32()
  self.goods_id = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
function SMysteryGoodsChangeInfo:sizepolicy(size)
  return size <= 65535
end
return SMysteryGoodsChangeInfo
