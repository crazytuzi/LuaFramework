local ModelInfo = require("netio.protocol.mzm.gsp.pubdata.ModelInfo")
local SQueryRoleModelInfoRes = class("SQueryRoleModelInfoRes")
SQueryRoleModelInfoRes.TYPEID = 12600837
function SQueryRoleModelInfoRes:ctor(roleid, modelinfo)
  self.id = 12600837
  self.roleid = roleid or nil
  self.modelinfo = modelinfo or ModelInfo.new()
end
function SQueryRoleModelInfoRes:marshal(os)
  os:marshalInt64(self.roleid)
  self.modelinfo:marshal(os)
end
function SQueryRoleModelInfoRes:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.modelinfo = ModelInfo.new()
  self.modelinfo:unmarshal(os)
end
function SQueryRoleModelInfoRes:sizepolicy(size)
  return size <= 65535
end
return SQueryRoleModelInfoRes
