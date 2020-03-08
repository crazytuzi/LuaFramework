local Location = require("netio.protocol.mzm.gsp.map.Location")
local STransforPosEnterView = class("STransforPosEnterView")
STransforPosEnterView.TYPEID = 12590884
function STransforPosEnterView:ctor(instanceId, pos, targetMapId)
  self.id = 12590884
  self.instanceId = instanceId or nil
  self.pos = pos or Location.new()
  self.targetMapId = targetMapId or nil
end
function STransforPosEnterView:marshal(os)
  os:marshalInt32(self.instanceId)
  self.pos:marshal(os)
  os:marshalInt32(self.targetMapId)
end
function STransforPosEnterView:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
  self.pos = Location.new()
  self.pos:unmarshal(os)
  self.targetMapId = os:unmarshalInt32()
end
function STransforPosEnterView:sizepolicy(size)
  return size <= 65535
end
return STransforPosEnterView
