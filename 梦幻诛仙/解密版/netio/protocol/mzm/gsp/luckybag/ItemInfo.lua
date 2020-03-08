local OctetsStream = require("netio.OctetsStream")
local ItemInfo = class("ItemInfo")
function ItemInfo:ctor(itemid, item_num)
  self.itemid = itemid or nil
  self.item_num = item_num or nil
end
function ItemInfo:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.item_num)
end
function ItemInfo:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.item_num = os:unmarshalInt32()
end
return ItemInfo
