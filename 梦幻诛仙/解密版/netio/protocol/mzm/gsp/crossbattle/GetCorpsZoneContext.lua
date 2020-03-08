local OctetsStream = require("netio.OctetsStream")
local GetCorpsZoneContext = class("GetCorpsZoneContext")
function GetCorpsZoneContext:ctor(count, roleid, corpsid)
  self.count = count or nil
  self.roleid = roleid or nil
  self.corpsid = corpsid or nil
end
function GetCorpsZoneContext:marshal(os)
  os:marshalInt32(self.count)
  os:marshalInt64(self.roleid)
  os:marshalInt64(self.corpsid)
end
function GetCorpsZoneContext:unmarshal(os)
  self.count = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.corpsid = os:unmarshalInt64()
end
return GetCorpsZoneContext
