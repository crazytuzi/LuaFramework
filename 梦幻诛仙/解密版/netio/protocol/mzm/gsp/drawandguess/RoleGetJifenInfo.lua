local OctetsStream = require("netio.OctetsStream")
local RoleGetJifenInfo = class("RoleGetJifenInfo")
function RoleGetJifenInfo:ctor(member_roleId, jifen)
  self.member_roleId = member_roleId or nil
  self.jifen = jifen or nil
end
function RoleGetJifenInfo:marshal(os)
  os:marshalInt64(self.member_roleId)
  os:marshalInt32(self.jifen)
end
function RoleGetJifenInfo:unmarshal(os)
  self.member_roleId = os:unmarshalInt64()
  self.jifen = os:unmarshalInt32()
end
return RoleGetJifenInfo
