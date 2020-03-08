local ParadeRoleInfo = require("netio.protocol.mzm.gsp.marriage.ParadeRoleInfo")
local SSynFriendParadeMsg = class("SSynFriendParadeMsg")
SSynFriendParadeMsg.TYPEID = 12599857
function SSynFriendParadeMsg:ctor(myInfo, coupleInfo, paradecfgid)
  self.id = 12599857
  self.myInfo = myInfo or ParadeRoleInfo.new()
  self.coupleInfo = coupleInfo or ParadeRoleInfo.new()
  self.paradecfgid = paradecfgid or nil
end
function SSynFriendParadeMsg:marshal(os)
  self.myInfo:marshal(os)
  self.coupleInfo:marshal(os)
  os:marshalInt32(self.paradecfgid)
end
function SSynFriendParadeMsg:unmarshal(os)
  self.myInfo = ParadeRoleInfo.new()
  self.myInfo:unmarshal(os)
  self.coupleInfo = ParadeRoleInfo.new()
  self.coupleInfo:unmarshal(os)
  self.paradecfgid = os:unmarshalInt32()
end
function SSynFriendParadeMsg:sizepolicy(size)
  return size <= 65535
end
return SSynFriendParadeMsg
