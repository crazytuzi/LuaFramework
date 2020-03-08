local OctetsStream = require("netio.OctetsStream")
local RoleInfo = require("netio.protocol.mzm.gsp.masswedding.RoleInfo")
local CoupleInfo = class("CoupleInfo")
function CoupleInfo:ctor(roleinfo1, roleinfo2)
  self.roleinfo1 = roleinfo1 or RoleInfo.new()
  self.roleinfo2 = roleinfo2 or RoleInfo.new()
end
function CoupleInfo:marshal(os)
  self.roleinfo1:marshal(os)
  self.roleinfo2:marshal(os)
end
function CoupleInfo:unmarshal(os)
  self.roleinfo1 = RoleInfo.new()
  self.roleinfo1:unmarshal(os)
  self.roleinfo2 = RoleInfo.new()
  self.roleinfo2:unmarshal(os)
end
return CoupleInfo
