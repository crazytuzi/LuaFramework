local ParadeRoleInfo = require("netio.protocol.mzm.gsp.marriage.ParadeRoleInfo")
local SBrocastStartParade = class("SBrocastStartParade")
SBrocastStartParade.TYPEID = 12599841
function SBrocastStartParade:ctor(role1Info, role2Info, paradecfgid)
  self.id = 12599841
  self.role1Info = role1Info or ParadeRoleInfo.new()
  self.role2Info = role2Info or ParadeRoleInfo.new()
  self.paradecfgid = paradecfgid or nil
end
function SBrocastStartParade:marshal(os)
  self.role1Info:marshal(os)
  self.role2Info:marshal(os)
  os:marshalInt32(self.paradecfgid)
end
function SBrocastStartParade:unmarshal(os)
  self.role1Info = ParadeRoleInfo.new()
  self.role1Info:unmarshal(os)
  self.role2Info = ParadeRoleInfo.new()
  self.role2Info:unmarshal(os)
  self.paradecfgid = os:unmarshalInt32()
end
function SBrocastStartParade:sizepolicy(size)
  return size <= 65535
end
return SBrocastStartParade
