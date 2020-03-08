local RoleInfo = require("netio.protocol.mzm.gsp.marriage.RoleInfo")
local SSynMarriageInfo = class("SSynMarriageInfo")
SSynMarriageInfo.TYPEID = 12599815
function SSynMarriageInfo:ctor(roleinfo, marrryTimeSec, marriageTitleid, roleid)
  self.id = 12599815
  self.roleinfo = roleinfo or RoleInfo.new()
  self.marrryTimeSec = marrryTimeSec or nil
  self.marriageTitleid = marriageTitleid or nil
  self.roleid = roleid or nil
end
function SSynMarriageInfo:marshal(os)
  self.roleinfo:marshal(os)
  os:marshalInt32(self.marrryTimeSec)
  os:marshalInt32(self.marriageTitleid)
  os:marshalInt64(self.roleid)
end
function SSynMarriageInfo:unmarshal(os)
  self.roleinfo = RoleInfo.new()
  self.roleinfo:unmarshal(os)
  self.marrryTimeSec = os:unmarshalInt32()
  self.marriageTitleid = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
end
function SSynMarriageInfo:sizepolicy(size)
  return size <= 65535
end
return SSynMarriageInfo
