local SZoneDrawLotsSuccess = class("SZoneDrawLotsSuccess")
SZoneDrawLotsSuccess.TYPEID = 12616999
function SZoneDrawLotsSuccess:ctor(activity_cfgid, zone)
  self.id = 12616999
  self.activity_cfgid = activity_cfgid or nil
  self.zone = zone or nil
end
function SZoneDrawLotsSuccess:marshal(os)
  os:marshalInt32(self.activity_cfgid)
  os:marshalInt32(self.zone)
end
function SZoneDrawLotsSuccess:unmarshal(os)
  self.activity_cfgid = os:unmarshalInt32()
  self.zone = os:unmarshalInt32()
end
function SZoneDrawLotsSuccess:sizepolicy(size)
  return size <= 65535
end
return SZoneDrawLotsSuccess
