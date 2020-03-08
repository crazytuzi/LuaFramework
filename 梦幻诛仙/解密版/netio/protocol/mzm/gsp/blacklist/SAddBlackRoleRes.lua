local BlackRole = require("netio.protocol.mzm.gsp.blacklist.BlackRole")
local SAddBlackRoleRes = class("SAddBlackRoleRes")
SAddBlackRoleRes.TYPEID = 12588548
function SAddBlackRoleRes:ctor(black_role)
  self.id = 12588548
  self.black_role = black_role or BlackRole.new()
end
function SAddBlackRoleRes:marshal(os)
  self.black_role:marshal(os)
end
function SAddBlackRoleRes:unmarshal(os)
  self.black_role = BlackRole.new()
  self.black_role:unmarshal(os)
end
function SAddBlackRoleRes:sizepolicy(size)
  return size <= 65535
end
return SAddBlackRoleRes
