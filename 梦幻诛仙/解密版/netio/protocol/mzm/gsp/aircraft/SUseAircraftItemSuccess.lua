local SUseAircraftItemSuccess = class("SUseAircraftItemSuccess")
SUseAircraftItemSuccess.TYPEID = 12624645
function SUseAircraftItemSuccess:ctor(add_aircraft_cfg_id)
  self.id = 12624645
  self.add_aircraft_cfg_id = add_aircraft_cfg_id or nil
end
function SUseAircraftItemSuccess:marshal(os)
  os:marshalInt32(self.add_aircraft_cfg_id)
end
function SUseAircraftItemSuccess:unmarshal(os)
  self.add_aircraft_cfg_id = os:unmarshalInt32()
end
function SUseAircraftItemSuccess:sizepolicy(size)
  return size <= 65535
end
return SUseAircraftItemSuccess
