local ChatContent = require("netio.protocol.mzm.gsp.chat.ChatContent")
local SChatInAllMap = class("SChatInAllMap")
SChatInAllMap.TYPEID = 12585265
function SChatInAllMap:ctor(map_cfg_id, content)
  self.id = 12585265
  self.map_cfg_id = map_cfg_id or nil
  self.content = content or ChatContent.new()
end
function SChatInAllMap:marshal(os)
  os:marshalInt32(self.map_cfg_id)
  self.content:marshal(os)
end
function SChatInAllMap:unmarshal(os)
  self.map_cfg_id = os:unmarshalInt32()
  self.content = ChatContent.new()
  self.content:unmarshal(os)
end
function SChatInAllMap:sizepolicy(size)
  return size <= 65535
end
return SChatInAllMap
