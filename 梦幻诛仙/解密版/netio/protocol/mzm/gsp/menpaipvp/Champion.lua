local OctetsStream = require("netio.OctetsStream")
local Champion = class("Champion")
function Champion:ctor(roleid, name, menpai)
  self.roleid = roleid or nil
  self.name = name or nil
  self.menpai = menpai or nil
end
function Champion:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalString(self.name)
  os:marshalInt32(self.menpai)
end
function Champion:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.name = os:unmarshalString()
  self.menpai = os:unmarshalInt32()
end
return Champion
