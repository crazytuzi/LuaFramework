local SpecialControlData = require("netio.protocol.mzm.gsp.activity.SpecialControlData")
local SynActivitySpecialControlChangeRes = class("SynActivitySpecialControlChangeRes")
SynActivitySpecialControlChangeRes.TYPEID = 12587603
function SynActivitySpecialControlChangeRes:ctor(specialControlData)
  self.id = 12587603
  self.specialControlData = specialControlData or SpecialControlData.new()
end
function SynActivitySpecialControlChangeRes:marshal(os)
  self.specialControlData:marshal(os)
end
function SynActivitySpecialControlChangeRes:unmarshal(os)
  self.specialControlData = SpecialControlData.new()
  self.specialControlData:unmarshal(os)
end
function SynActivitySpecialControlChangeRes:sizepolicy(size)
  return size <= 65535
end
return SynActivitySpecialControlChangeRes
