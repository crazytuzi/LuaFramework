local ShiTuActiveInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuActiveInfo")
local SynShiTuActiveInfo = class("SynShiTuActiveInfo")
SynShiTuActiveInfo.TYPEID = 12601652
function SynShiTuActiveInfo:ctor(shitu_active_info)
  self.id = 12601652
  self.shitu_active_info = shitu_active_info or ShiTuActiveInfo.new()
end
function SynShiTuActiveInfo:marshal(os)
  self.shitu_active_info:marshal(os)
end
function SynShiTuActiveInfo:unmarshal(os)
  self.shitu_active_info = ShiTuActiveInfo.new()
  self.shitu_active_info:unmarshal(os)
end
function SynShiTuActiveInfo:sizepolicy(size)
  return size <= 65535
end
return SynShiTuActiveInfo
