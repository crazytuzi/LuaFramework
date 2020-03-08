local OctetsStream = require("netio.OctetsStream")
local Item2Count = class("Item2Count")
function Item2Count:ctor(itemid, itemCount)
  self.itemid = itemid or nil
  self.itemCount = itemCount or nil
end
function Item2Count:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemCount)
end
function Item2Count:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.itemCount = os:unmarshalInt32()
end
return Item2Count
