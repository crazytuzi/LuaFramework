local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local SGetRoleModelRes = class("SGetRoleModelRes")
SGetRoleModelRes.TYPEID = 12589875
function SGetRoleModelRes:ctor(modelInfo)
  self.id = 12589875
  self.modelInfo = modelInfo or ModelInfo.new()
end
function SGetRoleModelRes:marshal(os)
  self.modelInfo:marshal(os)
end
function SGetRoleModelRes:unmarshal(os)
  self.modelInfo = ModelInfo.new()
  self.modelInfo:unmarshal(os)
end
function SGetRoleModelRes:sizepolicy(size)
  return size <= 65535
end
return SGetRoleModelRes
