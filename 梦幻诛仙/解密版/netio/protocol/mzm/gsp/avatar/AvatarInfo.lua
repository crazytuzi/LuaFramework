local OctetsStream = require("netio.OctetsStream")
local AvatarInfo = class("AvatarInfo")
function AvatarInfo:ctor(avatar, expire_time)
  self.avatar = avatar or nil
  self.expire_time = expire_time or nil
end
function AvatarInfo:marshal(os)
  os:marshalInt32(self.avatar)
  os:marshalInt64(self.expire_time)
end
function AvatarInfo:unmarshal(os)
  self.avatar = os:unmarshalInt32()
  self.expire_time = os:unmarshalInt64()
end
return AvatarInfo
