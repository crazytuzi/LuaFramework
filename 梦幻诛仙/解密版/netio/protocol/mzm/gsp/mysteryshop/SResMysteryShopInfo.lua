local SResMysteryShopInfo = class("SResMysteryShopInfo")
SResMysteryShopInfo.TYPEID = 12614404
function SResMysteryShopInfo:ctor(shoptype, refresh_times, used_free_refresh_times, can_free_refresh_times, goods_list)
  self.id = 12614404
  self.shoptype = shoptype or nil
  self.refresh_times = refresh_times or nil
  self.used_free_refresh_times = used_free_refresh_times or nil
  self.can_free_refresh_times = can_free_refresh_times or nil
  self.goods_list = goods_list or {}
end
function SResMysteryShopInfo:marshal(os)
  os:marshalInt32(self.shoptype)
  os:marshalInt32(self.refresh_times)
  os:marshalInt32(self.used_free_refresh_times)
  os:marshalInt32(self.can_free_refresh_times)
  os:marshalCompactUInt32(table.getn(self.goods_list))
  for _, v in ipairs(self.goods_list) do
    v:marshal(os)
  end
end
function SResMysteryShopInfo:unmarshal(os)
  self.shoptype = os:unmarshalInt32()
  self.refresh_times = os:unmarshalInt32()
  self.used_free_refresh_times = os:unmarshalInt32()
  self.can_free_refresh_times = os:unmarshalInt32()
  for _size_ = os:unmarshalCompactUInt32(), 1, -1 do
    local BeanClazz = require("netio.protocol.mzm.gsp.mysteryshop.MysteryGoodsInfo")
    local v = BeanClazz.new()
    v:unmarshal(os)
    table.insert(self.goods_list, v)
  end
end
function SResMysteryShopInfo:sizepolicy(size)
  return size <= 65535
end
return SResMysteryShopInfo
