local ParadeRoleInfo = require("netio.protocol.mzm.gsp.marriage.ParadeRoleInfo")
local SSynGangParadeMsg = class("SSynGangParadeMsg")
SSynGangParadeMsg.TYPEID = 12599858
function SSynGangParadeMsg:ctor(myInfo, coupleInfo, paradecfgid)
  self.id = 12599858
  self.myInfo = myInfo or ParadeRoleInfo.new()
  self.coupleInfo = coupleInfo or ParadeRoleInfo.new()
  self.paradecfgid = paradecfgid or nil
end
function SSynGangParadeMsg:marshal(os)
  self.myInfo:marshal(os)
  self.coupleInfo:marshal(os)
  os:marshalInt32(self.paradecfgid)
end
function SSynGangParadeMsg:unmarshal(os)
  self.myInfo = ParadeRoleInfo.new()
  self.myInfo:unmarshal(os)
  self.coupleInfo = ParadeRoleInfo.new()
  self.coupleInfo:unmarshal(os)
  self.paradecfgid = os:unmarshalInt32()
end
function SSynGangParadeMsg:sizepolicy(size)
  return size <= 65535
end
return SSynGangParadeMsg
