local OctetsStream = require("netio.OctetsStream")
local PlayEscape = class("PlayEscape")
PlayEscape.SUCCESS = 0
PlayEscape.FAIL = 1
function PlayEscape:ctor(fighterid, suc, sucRate)
  self.fighterid = fighterid or nil
  self.suc = suc or nil
  self.sucRate = sucRate or nil
end
function PlayEscape:marshal(os)
  os:marshalInt32(self.fighterid)
  os:marshalInt32(self.suc)
  os:marshalInt32(self.sucRate)
end
function PlayEscape:unmarshal(os)
  self.fighterid = os:unmarshalInt32()
  self.suc = os:unmarshalInt32()
  self.sucRate = os:unmarshalInt32()
end
return PlayEscape
