local OctetsStream = require("netio.OctetsStream")
local DressedInfo = class("DressedInfo")
function DressedInfo:ctor(fashion_cfgid, owner_roleid)
  self.fashion_cfgid = fashion_cfgid or nil
  self.owner_roleid = owner_roleid or nil
end
function DressedInfo:marshal(os)
  os:marshalInt32(self.fashion_cfgid)
  os:marshalInt64(self.owner_roleid)
end
function DressedInfo:unmarshal(os)
  self.fashion_cfgid = os:unmarshalInt32()
  self.owner_roleid = os:unmarshalInt64()
end
return DressedInfo
