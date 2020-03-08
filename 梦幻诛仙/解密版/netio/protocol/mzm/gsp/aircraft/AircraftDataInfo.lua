local OctetsStream = require("netio.OctetsStream")
local AircraftDataInfo = class("AircraftDataInfo")
function AircraftDataInfo:ctor(aircraft_cfg_id, dye_color_id)
  self.aircraft_cfg_id = aircraft_cfg_id or nil
  self.dye_color_id = dye_color_id or nil
end
function AircraftDataInfo:marshal(os)
  os:marshalInt32(self.aircraft_cfg_id)
  os:marshalInt32(self.dye_color_id)
end
function AircraftDataInfo:unmarshal(os)
  self.aircraft_cfg_id = os:unmarshalInt32()
  self.dye_color_id = os:unmarshalInt32()
end
return AircraftDataInfo
