local OctetsStream = require("netio.OctetsStream")
local YaoCaiShopItem = class("YaoCaiShopItem")
function YaoCaiShopItem:ctor(itemId, itemNum)
  self.itemId = itemId or nil
  self.itemNum = itemNum or nil
end
function YaoCaiShopItem:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.itemNum)
end
function YaoCaiShopItem:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
end
return YaoCaiShopItem
