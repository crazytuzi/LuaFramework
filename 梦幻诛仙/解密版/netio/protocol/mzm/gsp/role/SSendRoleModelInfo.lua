local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local SSendRoleModelInfo = class("SSendRoleModelInfo")
SSendRoleModelInfo.TYPEID = 12586028
function SSendRoleModelInfo:ctor(targetRoleId, model)
  self.id = 12586028
  self.targetRoleId = targetRoleId or nil
  self.model = model or ModelInfo.new()
end
function SSendRoleModelInfo:marshal(os)
  os:marshalInt64(self.targetRoleId)
  self.model:marshal(os)
end
function SSendRoleModelInfo:unmarshal(os)
  self.targetRoleId = os:unmarshalInt64()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
end
function SSendRoleModelInfo:sizepolicy(size)
  return size <= 65535
end
return SSendRoleModelInfo
