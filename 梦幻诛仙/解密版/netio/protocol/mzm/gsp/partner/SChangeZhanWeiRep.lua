local LineUp = require("netio.protocol.mzm.gsp.partner.LineUp")
local SChangeZhanWeiRep = class("SChangeZhanWeiRep")
SChangeZhanWeiRep.TYPEID = 12588044
function SChangeZhanWeiRep:ctor(lineUpNum, lineUp)
  self.id = 12588044
  self.lineUpNum = lineUpNum or nil
  self.lineUp = lineUp or LineUp.new()
end
function SChangeZhanWeiRep:marshal(os)
  os:marshalInt32(self.lineUpNum)
  self.lineUp:marshal(os)
end
function SChangeZhanWeiRep:unmarshal(os)
  self.lineUpNum = os:unmarshalInt32()
  self.lineUp = LineUp.new()
  self.lineUp:unmarshal(os)
end
function SChangeZhanWeiRep:sizepolicy(size)
  return size <= 65535
end
return SChangeZhanWeiRep
