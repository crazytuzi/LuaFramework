local CorpsSynInfo = require("netio.protocol.mzm.gsp.corps.CorpsSynInfo")
local SSyncCorpsInfo = class("SSyncCorpsInfo")
SSyncCorpsInfo.TYPEID = 12617486
function SSyncCorpsInfo:ctor(corpsInfo)
  self.id = 12617486
  self.corpsInfo = corpsInfo or CorpsSynInfo.new()
end
function SSyncCorpsInfo:marshal(os)
  self.corpsInfo:marshal(os)
end
function SSyncCorpsInfo:unmarshal(os)
  self.corpsInfo = CorpsSynInfo.new()
  self.corpsInfo:unmarshal(os)
end
function SSyncCorpsInfo:sizepolicy(size)
  return size <= 65535
end
return SSyncCorpsInfo
