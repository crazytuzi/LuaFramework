local OctetsStream = require("netio.OctetsStream")
local Play = class("Play")
function Play:ctor(play_type, content)
  self.play_type = play_type or nil
  self.content = content or nil
end
function Play:marshal(os)
  os:marshalInt32(self.play_type)
  os:marshalOctets(self.content)
end
function Play:unmarshal(os)
  self.play_type = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return Play
