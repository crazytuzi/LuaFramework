local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local SSynMemberModelChange = class("SSynMemberModelChange")
SSynMemberModelChange.TYPEID = 12617520
function SSynMemberModelChange:ctor(roleId, model)
  self.id = 12617520
  self.roleId = roleId or nil
  self.model = model or ModelInfo.new()
end
function SSynMemberModelChange:marshal(os)
  os:marshalInt64(self.roleId)
  self.model:marshal(os)
end
function SSynMemberModelChange:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.model = ModelInfo.new()
  self.model:unmarshal(os)
end
function SSynMemberModelChange:sizepolicy(size)
  return size <= 65535
end
return SSynMemberModelChange
