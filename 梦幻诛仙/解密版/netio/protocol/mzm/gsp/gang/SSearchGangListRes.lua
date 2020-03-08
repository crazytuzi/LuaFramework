local GangInfo = require("netio.protocol.mzm.gsp.gang.GangInfo")
local SSearchGangListRes = class("SSearchGangListRes")
SSearchGangListRes.TYPEID = 12589895
function SSearchGangListRes:ctor(result)
  self.id = 12589895
  self.result = result or GangInfo.new()
end
function SSearchGangListRes:marshal(os)
  self.result:marshal(os)
end
function SSearchGangListRes:unmarshal(os)
  self.result = GangInfo.new()
  self.result:unmarshal(os)
end
function SSearchGangListRes:sizepolicy(size)
  return size <= 65535
end
return SSearchGangListRes
