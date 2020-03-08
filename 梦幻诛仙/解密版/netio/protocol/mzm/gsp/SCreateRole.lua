local RoleInfo = require("netio.protocol.mzm.gsp.RoleInfo")
local SCreateRole = class("SCreateRole")
SCreateRole.TYPEID = 12590081
SCreateRole.ERR_SUCCESS = 0
SCreateRole.ERR_HAVE_ROLE = 1
SCreateRole.ERR_DUPLICATENAME = 2
SCreateRole.ERR_SENSITIVENAME = 3
SCreateRole.ERR_WRONGNAME = 4
SCreateRole.ERR_USER_FORBID = 5
SCreateRole.ERR_NO_CONFIG = 6
SCreateRole.ERR_UNKNOWN = 7
SCreateRole.ERR_WRONGSTATUS = 8
SCreateRole.ERR_FORBID_CREATE = 9
SCreateRole.ERR_REQUIRE_ACTIVATE = 10
SCreateRole.ERR_HAS_ROLE_IN_DELETE_STATE = 11
SCreateRole.ERR_ACCOUNT_NUM_LIMIT = 12
SCreateRole.ERR_CHANNEL_FORBID_CREATE = 13
SCreateRole.ERR_ROLE_NOT_OPEN = 14
function SCreateRole:ctor(result, roleinfo)
  self.id = 12590081
  self.result = result or nil
  self.roleinfo = roleinfo or RoleInfo.new()
end
function SCreateRole:marshal(os)
  os:marshalInt32(self.result)
  self.roleinfo:marshal(os)
end
function SCreateRole:unmarshal(os)
  self.result = os:unmarshalInt32()
  self.roleinfo = RoleInfo.new()
  self.roleinfo:unmarshal(os)
end
function SCreateRole:sizepolicy(size)
  return size <= 8192
end
return SCreateRole
