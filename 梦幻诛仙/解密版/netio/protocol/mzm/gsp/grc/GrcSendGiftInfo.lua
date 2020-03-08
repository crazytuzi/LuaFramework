local OctetsStream = require("netio.OctetsStream")
local GrcSendGiftInfo = class("GrcSendGiftInfo")
function GrcSendGiftInfo:ctor(to)
  self.to = to or nil
end
function GrcSendGiftInfo:marshal(os)
  os:marshalOctets(self.to)
end
function GrcSendGiftInfo:unmarshal(os)
  self.to = os:unmarshalOctets()
end
return GrcSendGiftInfo
