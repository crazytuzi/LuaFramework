local Location = require("netio.protocol.mzm.gsp.map.Location")
local SSyncSelfPosChange = class("SSyncSelfPosChange")
SSyncSelfPosChange.TYPEID = 12590853
function SSyncSelfPosChange:ctor(mapid, mapInstanceId, pos, targetPos, direction)
  self.id = 12590853
  self.mapid = mapid or nil
  self.mapInstanceId = mapInstanceId or nil
  self.pos = pos or Location.new()
  self.targetPos = targetPos or Location.new()
  self.direction = direction or nil
end
function SSyncSelfPosChange:marshal(os)
  os:marshalInt32(self.mapid)
  os:marshalInt32(self.mapInstanceId)
  self.pos:marshal(os)
  self.targetPos:marshal(os)
  os:marshalInt32(self.direction)
end
function SSyncSelfPosChange:unmarshal(os)
  self.mapid = os:unmarshalInt32()
  self.mapInstanceId = os:unmarshalInt32()
  self.pos = Location.new()
  self.pos:unmarshal(os)
  self.targetPos = Location.new()
  self.targetPos:unmarshal(os)
  self.direction = os:unmarshalInt32()
end
function SSyncSelfPosChange:sizepolicy(size)
  return size <= 65535
end
return SSyncSelfPosChange
