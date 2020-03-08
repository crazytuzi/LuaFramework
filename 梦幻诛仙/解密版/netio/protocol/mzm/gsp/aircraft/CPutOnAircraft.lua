local CPutOnAircraft = class("CPutOnAircraft")
CPutOnAircraft.TYPEID = 12624641
function CPutOnAircraft:ctor(aircraft_cfg_id)
  self.id = 12624641
  self.aircraft_cfg_id = aircraft_cfg_id or nil
end
function CPutOnAircraft:marshal(os)
  os:marshalInt32(self.aircraft_cfg_id)
end
function CPutOnAircraft:unmarshal(os)
  self.aircraft_cfg_id = os:unmarshalInt32()
end
function CPutOnAircraft:sizepolicy(size)
  return size <= 65535
end
return CPutOnAircraft
