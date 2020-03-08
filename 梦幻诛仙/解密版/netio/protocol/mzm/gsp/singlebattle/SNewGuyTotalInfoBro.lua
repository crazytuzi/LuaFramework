local RoleTotalInfo = require("netio.protocol.mzm.gsp.singlebattle.RoleTotalInfo")
local SNewGuyTotalInfoBro = class("SNewGuyTotalInfoBro")
SNewGuyTotalInfoBro.TYPEID = 12621606
function SNewGuyTotalInfoBro:ctor(roleId, campId, roleTotalInfo)
  self.id = 12621606
  self.roleId = roleId or nil
  self.campId = campId or nil
  self.roleTotalInfo = roleTotalInfo or RoleTotalInfo.new()
end
function SNewGuyTotalInfoBro:marshal(os)
  os:marshalInt64(self.roleId)
  os:marshalInt32(self.campId)
  self.roleTotalInfo:marshal(os)
end
function SNewGuyTotalInfoBro:unmarshal(os)
  self.roleId = os:unmarshalInt64()
  self.campId = os:unmarshalInt32()
  self.roleTotalInfo = RoleTotalInfo.new()
  self.roleTotalInfo:unmarshal(os)
end
function SNewGuyTotalInfoBro:sizepolicy(size)
  return size <= 65535
end
return SNewGuyTotalInfoBro
