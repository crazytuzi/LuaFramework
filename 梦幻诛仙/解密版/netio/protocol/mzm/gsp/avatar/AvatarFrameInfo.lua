local OctetsStream = require("netio.OctetsStream")
local AvatarFrameInfo = class("AvatarFrameInfo")
function AvatarFrameInfo:ctor(id, expire_time)
  self.id = id or nil
  self.expire_time = expire_time or nil
end
function AvatarFrameInfo:marshal(os)
  os:marshalInt32(self.id)
  os:marshalInt32(self.expire_time)
end
function AvatarFrameInfo:unmarshal(os)
  self.id = os:unmarshalInt32()
  self.expire_time = os:unmarshalInt32()
end
return AvatarFrameInfo
