local YaoDianInfo = require("netio.protocol.mzm.gsp.gang.YaoDianInfo")
local SYaoDianInfoRes = class("SYaoDianInfoRes")
SYaoDianInfoRes.TYPEID = 12589915
function SYaoDianInfoRes:ctor(yaoDianInfo)
  self.id = 12589915
  self.yaoDianInfo = yaoDianInfo or YaoDianInfo.new()
end
function SYaoDianInfoRes:marshal(os)
  self.yaoDianInfo:marshal(os)
end
function SYaoDianInfoRes:unmarshal(os)
  self.yaoDianInfo = YaoDianInfo.new()
  self.yaoDianInfo:unmarshal(os)
end
function SYaoDianInfoRes:sizepolicy(size)
  return size <= 65535
end
return SYaoDianInfoRes
