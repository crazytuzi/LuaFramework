local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMapNpcStopMove = class("SMapNpcStopMove")
SMapNpcStopMove.TYPEID = 12590894
function SMapNpcStopMove:ctor(npcId, currentLoc)
  self.id = 12590894
  self.npcId = npcId or nil
  self.currentLoc = currentLoc or Location.new()
end
function SMapNpcStopMove:marshal(os)
  os:marshalInt32(self.npcId)
  self.currentLoc:marshal(os)
end
function SMapNpcStopMove:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  self.currentLoc = Location.new()
  self.currentLoc:unmarshal(os)
end
function SMapNpcStopMove:sizepolicy(size)
  return size <= 65535
end
return SMapNpcStopMove
