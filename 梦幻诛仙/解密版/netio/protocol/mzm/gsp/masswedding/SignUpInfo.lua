local OctetsStream = require("netio.OctetsStream")
local SignUpInfo = class("SignUpInfo")
function SignUpInfo:ctor(roleid1, roleName1, roleid2, roleName2, price)
  self.roleid1 = roleid1 or nil
  self.roleName1 = roleName1 or nil
  self.roleid2 = roleid2 or nil
  self.roleName2 = roleName2 or nil
  self.price = price or nil
end
function SignUpInfo:marshal(os)
  os:marshalInt64(self.roleid1)
  os:marshalString(self.roleName1)
  os:marshalInt64(self.roleid2)
  os:marshalString(self.roleName2)
  os:marshalInt32(self.price)
end
function SignUpInfo:unmarshal(os)
  self.roleid1 = os:unmarshalInt64()
  self.roleName1 = os:unmarshalString()
  self.roleid2 = os:unmarshalInt64()
  self.roleName2 = os:unmarshalString()
  self.price = os:unmarshalInt32()
end
return SignUpInfo
