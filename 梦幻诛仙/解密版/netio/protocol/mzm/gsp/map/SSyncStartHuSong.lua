local Location = require("netio.protocol.mzm.gsp.map.Location")
local SSyncStartHuSong = class("SSyncStartHuSong")
SSyncStartHuSong.TYPEID = 12590897
function SSyncStartHuSong:ctor(is_special, targetPos)
  self.id = 12590897
  self.is_special = is_special or nil
  self.targetPos = targetPos or Location.new()
end
function SSyncStartHuSong:marshal(os)
  os:marshalUInt8(self.is_special)
  self.targetPos:marshal(os)
end
function SSyncStartHuSong:unmarshal(os)
  self.is_special = os:unmarshalUInt8()
  self.targetPos = Location.new()
  self.targetPos:unmarshal(os)
end
function SSyncStartHuSong:sizepolicy(size)
  return size <= 65535
end
return SSyncStartHuSong
