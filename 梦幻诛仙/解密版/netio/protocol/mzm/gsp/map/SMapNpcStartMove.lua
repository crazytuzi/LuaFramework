local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMapNpcStartMove = class("SMapNpcStartMove")
SMapNpcStartMove.TYPEID = 12590875
function SMapNpcStartMove:ctor(npcId, targetLoc, currentLoc, velocity)
  self.id = 12590875
  self.npcId = npcId or nil
  self.targetLoc = targetLoc or Location.new()
  self.currentLoc = currentLoc or Location.new()
  self.velocity = velocity or nil
end
function SMapNpcStartMove:marshal(os)
  os:marshalInt32(self.npcId)
  self.targetLoc:marshal(os)
  self.currentLoc:marshal(os)
  os:marshalInt32(self.velocity)
end
function SMapNpcStartMove:unmarshal(os)
  self.npcId = os:unmarshalInt32()
  self.targetLoc = Location.new()
  self.targetLoc:unmarshal(os)
  self.currentLoc = Location.new()
  self.currentLoc:unmarshal(os)
  self.velocity = os:unmarshalInt32()
end
function SMapNpcStartMove:sizepolicy(size)
  return size <= 65535
end
return SMapNpcStartMove
