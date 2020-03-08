local Location = require("netio.protocol.mzm.gsp.map.Location")
local SMarraigeParadePostion = class("SMarraigeParadePostion")
SMarraigeParadePostion.TYPEID = 12599844
function SMarraigeParadePostion:ctor(location, paradecfgid)
  self.id = 12599844
  self.location = location or Location.new()
  self.paradecfgid = paradecfgid or nil
end
function SMarraigeParadePostion:marshal(os)
  self.location:marshal(os)
  os:marshalInt32(self.paradecfgid)
end
function SMarraigeParadePostion:unmarshal(os)
  self.location = Location.new()
  self.location:unmarshal(os)
  self.paradecfgid = os:unmarshalInt32()
end
function SMarraigeParadePostion:sizepolicy(size)
  return size <= 65535
end
return SMarraigeParadePostion
