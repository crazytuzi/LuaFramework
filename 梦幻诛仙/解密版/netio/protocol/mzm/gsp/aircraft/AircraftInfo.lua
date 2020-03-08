local OctetsStream = require("netio.OctetsStream")
local AircraftInfo = class("AircraftInfo")
function AircraftInfo:ctor(dye_color_id)
  self.dye_color_id = dye_color_id or nil
end
function AircraftInfo:marshal(os)
  os:marshalInt32(self.dye_color_id)
end
function AircraftInfo:unmarshal(os)
  self.dye_color_id = os:unmarshalInt32()
end
return AircraftInfo
