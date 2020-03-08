local SDyeAircraftSuccess = class("SDyeAircraftSuccess")
SDyeAircraftSuccess.TYPEID = 12624646
function SDyeAircraftSuccess:ctor(aircraft_cfg_id, dye_color_id)
  self.id = 12624646
  self.aircraft_cfg_id = aircraft_cfg_id or nil
  self.dye_color_id = dye_color_id or nil
end
function SDyeAircraftSuccess:marshal(os)
  os:marshalInt32(self.aircraft_cfg_id)
  os:marshalInt32(self.dye_color_id)
end
function SDyeAircraftSuccess:unmarshal(os)
  self.aircraft_cfg_id = os:unmarshalInt32()
  self.dye_color_id = os:unmarshalInt32()
end
function SDyeAircraftSuccess:sizepolicy(size)
  return size <= 65535
end
return SDyeAircraftSuccess
