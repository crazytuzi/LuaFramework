local OctetsStream = require("netio.OctetsStream")
local OpItem = class("OpItem")
function OpItem:ctor(item_cfgid, main_target)
  self.item_cfgid = item_cfgid or nil
  self.main_target = main_target or nil
end
function OpItem:marshal(os)
  os:marshalInt32(self.item_cfgid)
  os:marshalInt32(self.main_target)
end
function OpItem:unmarshal(os)
  self.item_cfgid = os:unmarshalInt32()
  self.main_target = os:unmarshalInt32()
end
return OpItem
