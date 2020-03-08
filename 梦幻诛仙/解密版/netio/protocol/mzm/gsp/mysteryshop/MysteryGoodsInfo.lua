local OctetsStream = require("netio.OctetsStream")
local MysteryGoodsInfo = class("MysteryGoodsInfo")
function MysteryGoodsInfo:ctor(goods_id, sale, count)
  self.goods_id = goods_id or nil
  self.sale = sale or nil
  self.count = count or nil
end
function MysteryGoodsInfo:marshal(os)
  os:marshalInt32(self.goods_id)
  os:marshalInt32(self.sale)
  os:marshalInt32(self.count)
end
function MysteryGoodsInfo:unmarshal(os)
  self.goods_id = os:unmarshalInt32()
  self.sale = os:unmarshalInt32()
  self.count = os:unmarshalInt32()
end
return MysteryGoodsInfo
