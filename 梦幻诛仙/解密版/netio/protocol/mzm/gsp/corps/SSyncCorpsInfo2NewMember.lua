local CorpsSynInfo = require("netio.protocol.mzm.gsp.corps.CorpsSynInfo")
local SSyncCorpsInfo2NewMember = class("SSyncCorpsInfo2NewMember")
SSyncCorpsInfo2NewMember.TYPEID = 12617515
function SSyncCorpsInfo2NewMember:ctor(corpsInfo)
  self.id = 12617515
  self.corpsInfo = corpsInfo or CorpsSynInfo.new()
end
function SSyncCorpsInfo2NewMember:marshal(os)
  self.corpsInfo:marshal(os)
end
function SSyncCorpsInfo2NewMember:unmarshal(os)
  self.corpsInfo = CorpsSynInfo.new()
  self.corpsInfo:unmarshal(os)
end
function SSyncCorpsInfo2NewMember:sizepolicy(size)
  return size <= 65535
end
return SSyncCorpsInfo2NewMember
