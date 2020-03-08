local OctetsStream = require("netio.OctetsStream")
local GroupShoppingBanInfo = class("GroupShoppingBanInfo")
function GroupShoppingBanInfo:ctor(id, is_ban)
  self.id = id or nil
  self.is_ban = is_ban or nil
end
function GroupShoppingBanInfo:marshal(os)
  os:marshalInt32(self.id)
  os:marshalInt32(self.is_ban)
end
function GroupShoppingBanInfo:unmarshal(os)
  self.id = os:unmarshalInt32()
  self.is_ban = os:unmarshalInt32()
end
return GroupShoppingBanInfo
