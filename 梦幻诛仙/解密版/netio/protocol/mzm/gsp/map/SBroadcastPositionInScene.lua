local Location = require("netio.protocol.mzm.gsp.map.Location")
local SBroadcastPositionInScene = class("SBroadcastPositionInScene")
SBroadcastPositionInScene.TYPEID = 12590958
function SBroadcastPositionInScene:ctor(roleid, pos)
  self.id = 12590958
  self.roleid = roleid or nil
  self.pos = pos or Location.new()
end
function SBroadcastPositionInScene:marshal(os)
  os:marshalInt64(self.roleid)
  self.pos:marshal(os)
end
function SBroadcastPositionInScene:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.pos = Location.new()
  self.pos:unmarshal(os)
end
function SBroadcastPositionInScene:sizepolicy(size)
  return size <= 65535
end
return SBroadcastPositionInScene
