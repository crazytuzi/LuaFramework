local BuffInfo = require("netio.protocol.mzm.gsp.buff.BuffInfo")
local SAddBuff = class("SAddBuff")
SAddBuff.TYPEID = 12583171
function SAddBuff:ctor(buff)
  self.id = 12583171
  self.buff = buff or BuffInfo.new()
end
function SAddBuff:marshal(os)
  self.buff:marshal(os)
end
function SAddBuff:unmarshal(os)
  self.buff = BuffInfo.new()
  self.buff:unmarshal(os)
end
function SAddBuff:sizepolicy(size)
  return size <= 65535
end
return SAddBuff
