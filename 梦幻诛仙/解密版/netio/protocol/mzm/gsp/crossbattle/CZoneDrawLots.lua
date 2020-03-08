local CZoneDrawLots = class("CZoneDrawLots")
CZoneDrawLots.TYPEID = 12617000
function CZoneDrawLots:ctor(activity_cfgid)
  self.id = 12617000
  self.activity_cfgid = activity_cfgid or nil
end
function CZoneDrawLots:marshal(os)
  os:marshalInt32(self.activity_cfgid)
end
function CZoneDrawLots:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
end
function CZoneDrawLots:sizepolicy(size)
  return size <= 65535
end
return CZoneDrawLots
