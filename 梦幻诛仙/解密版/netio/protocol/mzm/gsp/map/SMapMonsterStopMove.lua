local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMapMonsterStopMove = class("SMapMonsterStopMove")
SMapMonsterStopMove.TYPEID = 12590882
function SMapMonsterStopMove:ctor(instanceId, currentLoc)
  self.id = 12590882
  self.instanceId = instanceId or nil
  self.currentLoc = currentLoc or Location.new()
end
function SMapMonsterStopMove:marshal(os)
  os:marshalInt32(self.instanceId)
  self.currentLoc:marshal(os)
end
function SMapMonsterStopMove:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
  self.currentLoc = Location.new()
  self.currentLoc:unmarshal(os)
end
function SMapMonsterStopMove:sizepolicy(size)
  return size <= 65535
end
return SMapMonsterStopMove
