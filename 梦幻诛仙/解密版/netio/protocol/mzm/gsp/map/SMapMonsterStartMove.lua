local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMapMonsterStartMove = class("SMapMonsterStartMove")
SMapMonsterStartMove.TYPEID = 12590867
function SMapMonsterStartMove:ctor(instanceId, targetLoc, currentLoc, velocity)
  self.id = 12590867
  self.instanceId = instanceId or nil
  self.targetLoc = targetLoc or Location.new()
  self.currentLoc = currentLoc or Location.new()
  self.velocity = velocity or nil
end
function SMapMonsterStartMove:marshal(os)
  os:marshalInt32(self.instanceId)
  self.targetLoc:marshal(os)
  self.currentLoc:marshal(os)
  os:marshalInt32(self.velocity)
end
function SMapMonsterStartMove:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
  self.targetLoc = Location.new()
  self.targetLoc:unmarshal(os)
  self.currentLoc = Location.new()
  self.currentLoc:unmarshal(os)
  self.velocity = os:unmarshalInt32()
end
function SMapMonsterStartMove:sizepolicy(size)
  return size <= 65535
end
return SMapMonsterStartMove
