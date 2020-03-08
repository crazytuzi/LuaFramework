local memberinfo = require("netio.protocol.mzm.gsp.sworn.memberinfo")
local SRoleJoin = class("SRoleJoin")
SRoleJoin.TYPEID = 12597791
function SRoleJoin:ctor(swornid, newmemberinfo)
  self.id = 12597791
  self.swornid = swornid or nil
  self.newmemberinfo = newmemberinfo or memberinfo.new()
end
function SRoleJoin:marshal(os)
  os:marshalInt64(self.swornid)
  self.newmemberinfo:marshal(os)
end
function SRoleJoin:unmarshal(os)
  self.swornid = os:unmarshalInt64()
  self.newmemberinfo = memberinfo.new()
  self.newmemberinfo:unmarshal(os)
end
function SRoleJoin:sizepolicy(size)
  return size <= 65535
end
return SRoleJoin
