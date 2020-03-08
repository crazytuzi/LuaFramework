local OctetsStream = require("netio.OctetsStream")
local IndianaAwardInfo = class("IndianaAwardInfo")
function IndianaAwardInfo:ctor(award_number, roleid, role_name)
  self.award_number = award_number or nil
  self.roleid = roleid or nil
  self.role_name = role_name or nil
end
function IndianaAwardInfo:marshal(os)
  os:marshalInt32(self.award_number)
  os:marshalInt64(self.roleid)
  os:marshalOctets(self.role_name)
end
function IndianaAwardInfo:unmarshal(os)
  self.award_number = os:unmarshalInt32()
  self.roleid = os:unmarshalInt64()
  self.role_name = os:unmarshalOctets()
end
return IndianaAwardInfo
