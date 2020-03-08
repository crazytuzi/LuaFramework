local OctetsStream = require("netio.OctetsStream")
local SimpleAdvertInfo = class("SimpleAdvertInfo")
function SimpleAdvertInfo:ctor(advertType, content)
  self.advertType = advertType or nil
  self.content = content or nil
end
function SimpleAdvertInfo:marshal(os)
  os:marshalInt32(self.advertType)
  os:marshalOctets(self.content)
end
function SimpleAdvertInfo:unmarshal(os)
  self.advertType = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return SimpleAdvertInfo
