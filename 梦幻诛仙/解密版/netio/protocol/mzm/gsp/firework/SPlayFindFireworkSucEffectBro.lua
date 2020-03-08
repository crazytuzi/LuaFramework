local Location = require("netio.protocol.mzm.gsp.map.Location")
local SPlayFindFireworkSucEffectBro = class("SPlayFindFireworkSucEffectBro")
SPlayFindFireworkSucEffectBro.TYPEID = 12625160
function SPlayFindFireworkSucEffectBro:ctor(mapId, location)
  self.id = 12625160
  self.mapId = mapId or nil
  self.location = location or Location.new()
end
function SPlayFindFireworkSucEffectBro:marshal(os)
  os:marshalInt32(self.mapId)
  self.location:marshal(os)
end
function SPlayFindFireworkSucEffectBro:unmarshal(os)
  self.mapId = os:unmarshalInt32()
  self.location = Location.new()
  self.location:unmarshal(os)
end
function SPlayFindFireworkSucEffectBro:sizepolicy(size)
  return size <= 65535
end
return SPlayFindFireworkSucEffectBro
