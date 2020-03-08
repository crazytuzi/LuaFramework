local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMapTeamTransferPos = class("SMapTeamTransferPos")
SMapTeamTransferPos.TYPEID = 12590902
function SMapTeamTransferPos:ctor(teamId, pos, targetPos, direction, mapId, mapInstanceId)
  self.id = 12590902
  self.teamId = teamId or nil
  self.pos = pos or Location.new()
  self.targetPos = targetPos or Location.new()
  self.direction = direction or nil
  self.mapId = mapId or nil
  self.mapInstanceId = mapInstanceId or nil
end
function SMapTeamTransferPos:marshal(os)
  os:marshalInt64(self.teamId)
  self.pos:marshal(os)
  self.targetPos:marshal(os)
  os:marshalInt32(self.direction)
  os:marshalInt32(self.mapId)
  os:marshalInt32(self.mapInstanceId)
end
function SMapTeamTransferPos:unmarshal(os)
  self.teamId = os:unmarshalInt64()
  self.pos = Location.new()
  self.pos:unmarshal(os)
  self.targetPos = Location.new()
  self.targetPos:unmarshal(os)
  self.direction = os:unmarshalInt32()
  self.mapId = os:unmarshalInt32()
  self.mapInstanceId = os:unmarshalInt32()
end
function SMapTeamTransferPos:sizepolicy(size)
  return size <= 65535
end
return SMapTeamTransferPos
