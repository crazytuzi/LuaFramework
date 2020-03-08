local OctetsStream = require("netio.OctetsStream")
local NeedItemBean = class("NeedItemBean")
function NeedItemBean:ctor(itemId, num)
  self.itemId = itemId or nil
  self.num = num or nil
end
function NeedItemBean:marshal(os)
  os:marshalInt32(self.itemId)
  os:marshalInt32(self.num)
end
function NeedItemBean:unmarshal(os)
  self.itemId = os:unmarshalInt32()
  self.num = os:unmarshalInt32()
end
return NeedItemBean
