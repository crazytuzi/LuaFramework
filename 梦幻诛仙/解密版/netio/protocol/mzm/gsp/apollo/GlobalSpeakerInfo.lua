local OctetsStream = require("netio.OctetsStream")
local GlobalSpeakerInfo = class("GlobalSpeakerInfo")
function GlobalSpeakerInfo:ctor(openid, nickname, is_open_mic)
  self.openid = openid or nil
  self.nickname = nickname or nil
  self.is_open_mic = is_open_mic or nil
end
function GlobalSpeakerInfo:marshal(os)
  os:marshalOctets(self.openid)
  os:marshalOctets(self.nickname)
  os:marshalUInt8(self.is_open_mic)
end
function GlobalSpeakerInfo:unmarshal(os)
  self.openid = os:unmarshalOctets()
  self.nickname = os:unmarshalOctets()
  self.is_open_mic = os:unmarshalUInt8()
end
return GlobalSpeakerInfo
