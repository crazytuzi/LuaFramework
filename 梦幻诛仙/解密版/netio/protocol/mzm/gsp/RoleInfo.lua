local OctetsStream = require("netio.OctetsStream")
local CreateRoleArg = require("netio.protocol.mzm.gsp.CreateRoleArg")
local RoleInfo = class("RoleInfo")
function RoleInfo:ctor(basic, roleid, expiretime, delEndtime, qqid)
  self.basic = basic or CreateRoleArg.new()
  self.roleid = roleid or nil
  self.expiretime = expiretime or nil
  self.delEndtime = delEndtime or nil
  self.qqid = qqid or nil
end
function RoleInfo:marshal(os)
  self.basic:marshal(os)
  os:marshalInt64(self.roleid)
  os:marshalInt64(self.expiretime)
  os:marshalInt32(self.delEndtime)
  os:marshalInt64(self.qqid)
end
function RoleInfo:unmarshal(os)
  self.basic = CreateRoleArg.new()
  self.basic:unmarshal(os)
  self.roleid = os:unmarshalInt64()
  self.expiretime = os:unmarshalInt64()
  self.delEndtime = os:unmarshalInt32()
  self.qqid = os:unmarshalInt64()
end
return RoleInfo
