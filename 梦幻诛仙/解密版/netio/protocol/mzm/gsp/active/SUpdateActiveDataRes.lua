local ActiveData = require("netio.protocol.mzm.gsp.active.ActiveData")
local SUpdateActiveDataRes = class("SUpdateActiveDataRes")
SUpdateActiveDataRes.TYPEID = 12599554
function SUpdateActiveDataRes:ctor(activeData)
  self.id = 12599554
  self.activeData = activeData or ActiveData.new()
end
function SUpdateActiveDataRes:marshal(os)
  self.activeData:marshal(os)
end
function SUpdateActiveDataRes:unmarshal(os)
  self.activeData = ActiveData.new()
  self.activeData:unmarshal(os)
end
function SUpdateActiveDataRes:sizepolicy(size)
  return size <= 65535
end
return SUpdateActiveDataRes
