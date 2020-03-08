local Location = require("netio.protocol.mzm.gsp.map.Location")
local CTransferMapReq = class("CTransferMapReq")
CTransferMapReq.TYPEID = 12590854
function CTransferMapReq:ctor(mapId, targetPos)
  self.id = 12590854
  self.mapId = mapId or nil
  self.targetPos = targetPos or Location.new()
end
function CTransferMapReq:marshal(os)
  os:marshalInt32(self.mapId)
  self.targetPos:marshal(os)
end
function CTransferMapReq:unmarshal(os)
  self.mapId = os:unmarshalInt32()
  self.targetPos = Location.new()
  self.targetPos:unmarshal(os)
end
function CTransferMapReq:sizepolicy(size)
  return size <= 65535
end
return CTransferMapReq
