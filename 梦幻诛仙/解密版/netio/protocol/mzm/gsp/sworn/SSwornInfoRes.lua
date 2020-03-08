local sworninfo = require("netio.protocol.mzm.gsp.sworn.sworninfo")
local SSwornInfoRes = class("SSwornInfoRes")
SSwornInfoRes.TYPEID = 12597786
function SSwornInfoRes:ctor(info)
  self.id = 12597786
  self.info = info or sworninfo.new()
end
function SSwornInfoRes:marshal(os)
  self.info:marshal(os)
end
function SSwornInfoRes:unmarshal(os)
  self.info = sworninfo.new()
  self.info:unmarshal(os)
end
function SSwornInfoRes:sizepolicy(size)
  return size <= 65535
end
return SSwornInfoRes
