local OctetsStream = require("netio.OctetsStream")
local Item2Count = class("Item2Count")
function Item2Count:ctor(itemid, itemcount)
  self.itemid = itemid or nil
  self.itemcount = itemcount or nil
end
function Item2Count:marshal(os)
  os:marshalInt32(self.itemid)
  os:marshalInt32(self.itemcount)
end
function Item2Count:unmarshal(os)
  self.itemid = os:unmarshalInt32()
  self.itemcount = os:unmarshalInt32()
end
return Item2Count
