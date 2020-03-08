local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMapItemEnterView = class("SMapItemEnterView")
SMapItemEnterView.TYPEID = 12590862
function SMapItemEnterView:ctor(instanceId, mapItemCfgId, loc)
  self.id = 12590862
  self.instanceId = instanceId or nil
  self.mapItemCfgId = mapItemCfgId or nil
  self.loc = loc or Location.new()
end
function SMapItemEnterView:marshal(os)
  os:marshalInt32(self.instanceId)
  os:marshalInt32(self.mapItemCfgId)
  self.loc:marshal(os)
end
function SMapItemEnterView:unmarshal(os)
  self.instanceId = os:unmarshalInt32()
  self.mapItemCfgId = os:unmarshalInt32()
  self.loc = Location.new()
  self.loc:unmarshal(os)
end
function SMapItemEnterView:sizepolicy(size)
  return size <= 65535
end
return SMapItemEnterView
