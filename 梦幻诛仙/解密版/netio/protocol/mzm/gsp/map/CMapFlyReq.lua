local Location = require("netio.protocol.mzm.gsp.map.Location")
local CMapFlyReq = class("CMapFlyReq")
CMapFlyReq.TYPEID = 12590878
function CMapFlyReq:ctor(targetPos)
  self.id = 12590878
  self.targetPos = targetPos or Location.new()
end
function CMapFlyReq:marshal(os)
  self.targetPos:marshal(os)
end
function CMapFlyReq:unmarshal(os)
  self.targetPos = Location.new()
  self.targetPos:unmarshal(os)
end
function CMapFlyReq:sizepolicy(size)
  return size <= 65535
end
return CMapFlyReq
