local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInGroup = class("SChatInGroup")
SChatInGroup.TYPEID = 12585254
function SChatInGroup:ctor(groupid, content)
  self.id = 12585254
  self.groupid = groupid or nil
  self.content = content or ChatContent.new()
end
function SChatInGroup:marshal(os)
  os:marshalInt64(self.groupid)
  self.content:marshal(os)
end
function SChatInGroup:unmarshal(os)
  self.groupid = os:unmarshalInt64()
  self.content = ChatContent.new()
  self.content:unmarshal(os)
end
function SChatInGroup:sizepolicy(size)
  return size <= 65535
end
return SChatInGroup
