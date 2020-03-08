local SPutOnAircraftSuccess = class("SPutOnAircraftSuccess")
SPutOnAircraftSuccess.TYPEID = 12624644
function SPutOnAircraftSuccess:ctor(aircraft_cfg_id)
  self.id = 12624644
  self.aircraft_cfg_id = aircraft_cfg_id or nil
end
function SPutOnAircraftSuccess:marshal(os)
  os:marshalInt32(self.aircraft_cfg_id)
end
function SPutOnAircraftSuccess:unmarshal(os)
  self.aircraft_cfg_id = os:unmarshalInt32()
end
function SPutOnAircraftSuccess:sizepolicy(size)
  return size <= 65535
end
return SPutOnAircraftSuccess
