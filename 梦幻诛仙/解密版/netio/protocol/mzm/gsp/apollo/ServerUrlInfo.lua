local OctetsStream = require("netio.OctetsStream")
local ServerUrlInfo = class("ServerUrlInfo")
function ServerUrlInfo:ctor(url)
  self.url = url or nil
end
function ServerUrlInfo:marshal(os)
  os:marshalOctets(self.url)
end
function ServerUrlInfo:unmarshal(os)
  self.url = os:unmarshalOctets()
end
return ServerUrlInfo
