local ItemInfo = require("netio.protocol.mzm.gsp.item.ItemInfo")
local SQueryItemRes = class("SQueryItemRes")
SQueryItemRes.TYPEID = 12584985
function SQueryItemRes:ctor(index, itemid, price, iteminfo)
  self.id = 12584985
  self.index = index or nil
  self.itemid = itemid or nil
  self.price = price or nil
  self.iteminfo = iteminfo or ItemInfo.new()
end
function SQueryItemRes:marshal(os)
  os:marshalInt32(self.index)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.price)
  self.iteminfo:marshal(os)
end
function SQueryItemRes:unmarshal(os)
  self.index = os:unmarshalInt32()
  self.itemid = os:unmarshalInt32()
  self.price = os:unmarshalInt32()
  self.iteminfo = ItemInfo.new()
  self.iteminfo:unmarshal(os)
end
function SQueryItemRes:sizepolicy(size)
  return size <= 65535
end
return SQueryItemRes
