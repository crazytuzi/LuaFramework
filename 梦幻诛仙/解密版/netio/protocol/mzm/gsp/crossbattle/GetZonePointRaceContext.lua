local OctetsStream = require("netio.OctetsStream")
local GetZonePointRaceContext = class("GetZonePointRaceContext")
GetZonePointRaceContext.GET_POINT_RACE_DATA = 1
GetZonePointRaceContext.GET_POINT_RACE_RESULT = 2
function GetZonePointRaceContext:ctor(oper_type, content)
  self.oper_type = oper_type or nil
  self.content = content or nil
end
function GetZonePointRaceContext:marshal(os)
  os:marshalInt32(self.oper_type)
  os:marshalOctets(self.content)
end
function GetZonePointRaceContext:unmarshal(os)
  self.oper_type = os:unmarshalInt32()
  self.content = os:unmarshalOctets()
end
return GetZonePointRaceContext
