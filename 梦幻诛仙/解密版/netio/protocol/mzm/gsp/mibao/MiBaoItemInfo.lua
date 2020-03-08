local OctetsStream = require("netio.OctetsStream")
local MiBaoItemInfo = class("MiBaoItemInfo")
function MiBaoItemInfo:ctor(itemId, itemNum)
  self.itemId = itemId or nil
  self.itemNum = itemNum or nil
end
function MiBaoItemInfo:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.itemNum)
end
function MiBaoItemInfo:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.itemNum = os:unmarshalInt32()
end
return MiBaoItemInfo
