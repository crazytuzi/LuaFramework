local OctetsStream = require("netio.OctetsStream")
local MonsterInfo = class("MonsterInfo")
function MonsterInfo:ctor(monsterid, state, seq, content)
  self.monsterid = monsterid or nil
  self.state = state or nil
  self.seq = seq or nil
  self.content = content or nil
end
function MonsterInfo:marshal(os)
  os:marshalInt32(self.monsterid)
  os:marshalInt32(self.state)
  os:marshalInt32(self.seq)
  os:marshalOctets(self.content)
end
function MonsterInfo:unmarshal(os)
  self.monsterid = os:unmarshalInt32()
  self.state = os:unmarshalInt32()
  self.seq = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return MonsterInfo
