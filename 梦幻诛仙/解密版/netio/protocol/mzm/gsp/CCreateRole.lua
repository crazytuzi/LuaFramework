local CreateRoleArg = require("netio.protocol.mzm.gsp.CreateRoleArg")
local CCreateRole = class("CCreateRole")
CCreateRole.TYPEID = 12590087
function CCreateRole:ctor(roleinfo)
  self.id = 12590087
  self.roleinfo = roleinfo or CreateRoleArg.new()
end
function CCreateRole:marshal(os)
  self.roleinfo:marshal(os)
end
function CCreateRole:unmarshal(os)
  self.roleinfo = CreateRoleArg.new()
  self.roleinfo:unmarshal(os)
end
function CCreateRole:sizepolicy(size)
  return size <= 8192
end
return CCreateRole
