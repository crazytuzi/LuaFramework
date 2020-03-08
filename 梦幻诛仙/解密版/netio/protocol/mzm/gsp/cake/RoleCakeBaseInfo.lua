local OctetsStream = require("netio.OctetsStream")
local CakeDetailInfo = require("netio.protocol.mzm.gsp.cake.CakeDetailInfo")
local RoleCakeBaseInfo = class("RoleCakeBaseInfo")
function RoleCakeBaseInfo:ctor(roleName, cakeInfo)
  self.roleName = roleName or nil
  self.cakeInfo = cakeInfo or CakeDetailInfo.new()
end
function RoleCakeBaseInfo:marshal(os)
  os:marshalOctets(self.roleName)
  self.cakeInfo:marshal(os)
end
function RoleCakeBaseInfo:unmarshal(os)
  self.roleName = os:unmarshalOctets()
  self.cakeInfo = CakeDetailInfo.new()
  self.cakeInfo:unmarshal(os)
end
return RoleCakeBaseInfo
